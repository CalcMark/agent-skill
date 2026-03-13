---
name: calcmark
description: Use CalcMark to perform calculations, create computational documents, and produce analysis artifacts (.cm files, HTML, JSON, Markdown). Activate when the user needs cost modeling, capacity planning, unit conversions, date arithmetic, napkin math, or any quantitative analysis.
allowed-tools: Bash(cm:*), Bash(brew:*), Bash(which:*), Bash(uname:*), Bash(curl:*), Read, Write, WebFetch
---

# CalcMark Agent Skill

CalcMark is a calculation language that blends CommonMark markdown with inline calculations -- budgets, capacity plans, cost models, project estimates. Think "spreadsheet meets markdown."

## First Use

Before your first calculation, fetch the full reference:

```
WebFetch https://calcmark.org/docs/agent-integration/
```

This gives you installation instructions, the complete syntax reference, function table with NL forms, smart type handling rules, frontmatter configuration, workflow patterns, and JSON output format.

## Quick Reference

If you already have `cm` installed and need a reminder:

### CLI Patterns

```bash
# One-liner
echo "compound $10000 by 7% over 30 years" | cm --format json

# Heredoc
cm --format json <<'EOF'
servers = 50000 req/s at 2000 req/s per server with 25% buffer
cost = $450 * servers
EOF

# File
cm eval budget.cm --format json

# Convert to HTML
cm convert report.cm --to=html -o report.html
```

### Runtime Discovery

```bash
cm help functions    # All functions with signatures and NL forms
cm help constants    # All unit constants
cm help frontmatter  # All frontmatter directives
```

### Key Syntax

```calcmark
price = $100                                          # currency
total = price * 12                                    # arithmetic
marked_up = price + 15%                               # percentage widening
marathon = 42.195 km in miles                         # unit conversion
deadline = Jun 30 2026                                # dates
remaining = deadline - today                          # date arithmetic
api_rate = 1200 req/s                                 # rates
daily_requests = api_rate over 1 day                  # rate accumulation
servers = 50000 req/s at 2000 req/s per server        # capacity planning
compound $10000 by 7% monthly over 30 years           # compound growth
depreciate $50000 by 15% over 5 years                 # depreciation
read 100 MB from ssd                                  # storage I/O
transfer 500 KB across regional gigabit               # network transfer
1234567 as napkin                                     # napkin math (~1.2M)
```

### Smart Type Handling

- `$49 * 2500 customers` → `$122,500.00` (currency * quantity = currency)
- `€4500 in USD` → converts using frontmatter exchange rates
- Use `number()` only for dimensionless ratios: `number(ltv) / number(cac)`

### Workflow Patterns

1. **Quick calc**: pipe one-liner, extract `numeric_value` from JSON
2. **Research artifact**: write `.cm` file, `cm eval` for JSON evidence
3. **Document deliverable**: write `.cm` with `{{templates}}`, `cm convert --to=html`

### Error Handling

- Errors go to **stderr** (not JSON). Check exit code.
- If output has `"type": "text"` instead of `"type": "calculation"`, the expression was treated as prose.

### Security

- Ask user before installing `cm`
- Write `.cm` files only in the project directory or temp directory
