#
# 根据删除列表剪辑视频（filter_complex 精确剪辑）- Windows PowerShell 版本
#
# 用法: .\cut_video.ps1 <input.mp4> <delete_segments.json> [output.mp4]
#

param(
    [Parameter(Mandatory=$true)]
    [string]$Input,

    [Parameter(Mandatory=$true)]
    [string]$DeleteJson,

    [string]$Output = "output_cut.mp4"
)

# 检查文件
if (-not (Test-Path $Input)) {
    Write-Host "❌ 找不到输入文件: $Input"
    exit 1
}

if (-not (Test-Path $DeleteJson)) {
    Write-Host "❌ 找不到删除列表: $DeleteJson"
    exit 1
}

# 获取视频时长
$Duration = ffprobe -v error -show_entries format=duration -of csv=p=0 "file:$Input" 2>$null
Write-Host "📹 视频时长: ${Duration}s"

# 配置参数
$BufferMs = 50      # 删除范围前后各扩展 50ms（吃掉气口）
$CrossfadeMs = 30   # 音频淡入淡出 30ms

Write-Host "⚙️ 优化参数: 扩展范围=${BufferMs}ms, 音频crossfade=${CrossfadeMs}ms"

# 用 node 生成 filter_complex 命令
$FilterCmd = node -e "
const fs = require('fs');
const deleteSegs = JSON.parse(fs.readFileSync('$DeleteJson', 'utf8'));
const duration = $Duration;
const bufferSec = $BufferMs / 1000;
const crossfadeSec = $CrossfadeMs / 1000;

// 按开始时间排序
deleteSegs.sort((a, b) => a.start - b.start);

// 扩展删除范围（前后各加 buffer）
const expandedSegs = deleteSegs.map(seg => ({
  start: Math.max(0, seg.start - bufferSec),
  end: Math.min(duration, seg.end + bufferSec)
}));

// 合并重叠的删除段
const mergedSegs = [];
for (const seg of expandedSegs) {
  if (mergedSegs.length === 0 || seg.start > mergedSegs[mergedSegs.length - 1].end) {
    mergedSegs.push({ ...seg });
  } else {
    mergedSegs[mergedSegs.length - 1].end = Math.max(mergedSegs[mergedSegs.length - 1].end, seg.end);
  }
}

// 计算保留片段
const keepSegs = [];
let cursor = 0;

for (const del of mergedSegs) {
  if (del.start > cursor) {
    keepSegs.push({ start: cursor, end: del.start });
  }
  cursor = del.end;
}

if (cursor < duration) {
  keepSegs.push({ start: cursor, end: duration });
}

console.error('保留片段数:', keepSegs.length);
console.error('删除片段数:', mergedSegs.length);

let deletedTime = 0;
for (const seg of mergedSegs) {
  deletedTime += seg.end - seg.start;
}
console.error('删除总时长:', deletedTime.toFixed(2) + 's');

// 生成 filter_complex（带 crossfade）
let filters = [];
let vconcat = '';
let aLabels = [];

for (let i = 0; i < keepSegs.length; i++) {
  const seg = keepSegs[i];
  filters.push('[0:v]trim=start=' + seg.start.toFixed(3) + ':end=' + seg.end.toFixed(3) + ',setpts=PTS-STARTPTS[v' + i + ']');
  filters.push('[0:a]atrim=start=' + seg.start.toFixed(3) + ':end=' + seg.end.toFixed(3) + ',asetpts=PTS-STARTPTS[a' + i + ']');
  vconcat += '[v' + i + ']';
  aLabels.push('a' + i);
}

// 视频直接 concat
filters.push(vconcat + 'concat=n=' + keepSegs.length + ':v=1:a=0[outv]');

// 音频使用 acrossfade 逐个拼接
if (keepSegs.length === 1) {
  filters.push('[a0]anull[outa]');
} else {
  let currentLabel = 'a0';
  for (let i = 1; i < keepSegs.length; i++) {
    const nextLabel = 'a' + i;
    const outLabel = (i === keepSegs.length - 1) ? 'outa' : 'amid' + i;
    filters.push('[' + currentLabel + '][' + nextLabel + ']acrossfade=d=' + crossfadeSec.toFixed(3) + ':c1=tri:c2=tri[' + outLabel + ']');
    currentLabel = outLabel;
  }
}

console.log(filters.join(';'));
"

if (-not $FilterCmd) {
    Write-Host "❌ 生成滤镜命令失败"
    exit 1
}

Write-Host ""
Write-Host "✂️ 执行 FFmpeg 精确剪辑..."

ffmpeg -y -i "file:$Input" -filter_complex $FilterCmd -map "[outv]" -map "[outa]" -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 192k "file:$Output"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 已保存: $Output"

    $NewDuration = ffprobe -v error -show_entries format=duration -of csv=p=0 "file:$Output" 2>$null
    Write-Host "📹 新时长: ${NewDuration}s"
} else {
    Write-Host "❌ 剪辑失败"
    exit 1
}
