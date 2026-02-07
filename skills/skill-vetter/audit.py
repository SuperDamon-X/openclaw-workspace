#!/usr/bin/env python3
"""
Skill Vetter - 安全审计工具
用于评估技能的安全风险
"""

import re
import json
import sys
from pathlib import Path
from datetime import datetime

class RiskLevel:
    HIGH = "🔴 高风险"
    MEDIUM = "🟡 中风险"
    LOW = "🟢 低风险"

class Risk:
    def __init__(self, category, description, details, impact, suggestion):
        self.category = category
        self.description = description
        self.details = details
        self.impact = impact
        self.suggestion = suggestion

class SkillAuditor:
    def __init__(self, skill_path):
        self.skill_path = Path(skill_path)
        self.risks = []
        self.assumptions = []

    def read_skill_config(self):
        """读取技能配置"""
        skill_md = self.skill_path / "SKILL.md"
        package_json = self.skill_path / "package.json"

        config = {
            "has_skill_md": skill_md.exists(),
            "has_package_json": package_json.exists(),
        }

        if config["has_skill_md"]:
            with open(skill_md, 'r', encoding='utf-8') as f:
                config["skill_md_content"] = f.read()

        if config["has_package_json"]:
            with open(package_json, 'r', encoding='utf-8') as f:
                config["package_json"] = json.load(f)

        return config

    def audit_permissions(self, config):
        """审计权限要求"""
        risks = []

        # 检查敏感路径访问
        sensitive_paths = [
            "~/.ssh", "~/.aws", "~/.gnupg",
            "~/.config/gh", "*key*", "*secret*", "*password*", "*token*"
        ]

        if config.get("has_skill_md"):
            content = config.get("skill_md_content", "").lower()

            for pattern in sensitive_paths:
                if pattern.replace("*", "") in content:
                    risks.append(Risk(
                        category="权限风险",
                        description=f"检测到对敏感路径的访问请求：{pattern}",
                        details="技能配置中提及访问包含敏感关键词的路径",
                        impact="可能读取或泄露敏感凭证（SSH 密钥、API 密钥等）",
                        suggestion="审查代码逻辑，确认是否需要访问敏感数据"
                    ))

        # 检查文件操作
        if "rm -rf" in content or "delete" in content:
            risks.append(Risk(
                category="权限风险",
                description="检测到删除操作",
                details="技能配置中包含文件删除指令",
                impact="可能意外删除用户数据",
                suggestion="审查删除逻辑，确保有明确用户确认"
            ))

        # 检查网络访问
        if "fetch" in content or "http" in content or "api" in content:
            risks.append(Risk(
                category="网络风险",
                description="检测到网络访问请求",
                details="技能可能发起外部网络请求",
                impact="数据可能上传到未验证的服务器",
                suggestion="检查所有外连 URL，确保使用 HTTPS 且来源可信"
            ))

        return risks

    def audit_dependencies(self, config):
        """审计第三方依赖"""
        risks = []

        if config.get("has_package_json"):
            package = config.get("package_json", {})
            dependencies = package.get("dependencies", {})

            if dependencies:
                deps_count = len(dependencies)
                risks.append(Risk(
                    category="供应链风险",
                    description=f"检测到 {deps_count} 个第三方依赖",
                    details=f"依赖列表：{list(dependencies.keys())}",
                    impact="第三方依赖可能包含安全漏洞或被投毒",
                    suggestion=f"审查依赖包安全性，定期更新依赖版本"
                ))

                # 检查高风险依赖
                high_risk_packages = ["axios", "request", "lodash"]  # 历史上有漏洞的包
                for dep in dependencies:
                    if dep.lower() in high_risk_packages:
                        risks.append(Risk(
                            category="供应链风险",
                            description=f"使用历史有漏洞的依赖：{dep}",
                            details=f"{dep} 曾报道过安全漏洞",
                            impact="可能被利用进行攻击",
                            suggestion=f"升级到最新版本或使用替代方案"
                        ))

        return risks

    def audit_code_patterns(self, config):
        """审计代码模式"""
        risks = []

        if config.get("has_skill_md"):
            content = config.get("skill_md_content", "")

            # 检查 eval
            if "eval(" in content:
                risks.append(Risk(
                    category="安全漏洞",
                    description="检测到动态代码执行",
                    details="代码中包含 eval() 函数调用",
                    impact="可能执行任意代码，存在命令注入风险",
                    suggestion="审查 eval 用途，避免处理不可信输入"
                ))

            # 检查 subprocess/shell
            if "subprocess" in content or "shell=True" in content:
                risks.append(Risk(
                    category="安全漏洞",
                    description="检测到命令执行",
                    details="代码中包含命令执行逻辑",
                    impact="可能被利用执行恶意命令",
                    suggestion="审查命令参数来源，确保有输入验证"
                ))

        return risks

    def audit_transparency(self, config):
        """审计透明度"""
        risks = []

        if not config.get("has_skill_md"):
            risks.append(Risk(
                category="透明度风险",
                description="缺少 SKILL.md 文档",
                details="技能目录未提供说明文档",
                impact="无法了解技能用途和安全实践",
                suggestion="要求开发者提供 SKILL.md"
            ))

        return risks

    def assess_overall_risk(self, risks):
        """评估总体风险等级"""
        if not risks:
            return RiskLevel.LOW

        high_risk_count = sum(1 for r in risks if "高" in r.description or r.category in ["安全漏洞", "恶意行为"])
        medium_risk_count = sum(1 for r in risks if "中" in r.description or r.category in ["权限风险", "网络风险"])

        if high_risk_count >= 1:
            return RiskLevel.HIGH
        elif medium_risk_count >= 2 or high_risk_count >= 1:
            return RiskLevel.MEDIUM
        else:
            return RiskLevel.LOW

    def generate_report(self, skill_info=None):
        """生成审计报告"""
        config = self.read_skill_config()

        # 执行各项审计
        self.risks = []
        self.risks.extend(self.audit_permissions(config))
        self.risks.extend(self.audit_dependencies(config))
        self.risks.extend(self.audit_code_patterns(config))
        self.risks.extend(self.audit_transparency(config))

        # 评估总体风险
        overall_risk = self.assess_overall_risk(self.risks)

        # 生成报告
        report = []
        report.append("=" * 40)
        report.append("安全审计报告")
        report.append("=" * 40)
        report.append(f"审计时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"技能路径：{self.skill_path}")
        report.append("")

        report.append("【总体风险评级】" + overall_risk)
        report.append("")

        if self.risks:
            report.append("【风险点列表】")
            report.append("")

            for i, risk in enumerate(self.risks, 1):
                report.append(f"风险点 {i}：{risk.category} - {risk.description}")
                report.append(f"- 详细说明：{risk.details}")
                report.append(f"- 潜在影响：{risk.impact}")
                report.append(f"- 安全建议：{risk.suggestion}")
                report.append("")
        else:
            report.append("✅ 未发现明显安全风险")
            report.append("")

        if self.assumptions:
            report.append("【审计假设】")
            for assumption in self.assumptions:
                report.append(f"- {assumption}")
            report.append("")

        # 最终建议
        report.append("【最终建议】")

        if overall_risk == RiskLevel.HIGH:
            report.append("❌ 不建议安装")
            report.append("存在严重安全风险或恶意行为模式")
            report.append("如果必须安装，请：")
            report.append("- 手动审查所有代码")
            report.append("- 在沙盒环境中测试")
            report.append("- 监控安装后的网络和系统活动")
        elif overall_risk == RiskLevel.MEDIUM:
            report.append("⚠️ 谨慎安装")
            report.append("存在潜在风险，需要额外验证")
            report.append("建议：")
            report.append("- 仔细阅读代码逻辑")
            report.append("- 确认所有网络请求的来源")
            report.append("- 在受限环境中测试")
        else:
            report.append("✅ 可以安装")
            report.append("风险可控，符合安全最佳实践")
            report.append("建议：")
            report.append("- 定期更新技能")
            report.append("- 关注安全公告")

        return "\n".join(report)

def main():
    if len(sys.argv) < 2:
        print("用法：python audit.py <skill_path>")
        sys.exit(1)

    skill_path = sys.argv[1]
    auditor = SkillAuditor(skill_path)
    print(auditor.generate_report())

if __name__ == "__main__":
    main()
