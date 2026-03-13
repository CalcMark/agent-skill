---
name: calcmark
description: >
  Use this skill when working with CalcMark (.cm) files or performing quantitative analysis.
  CalcMark blends CommonMark markdown with inline calculations for cost modeling,
  capacity planning, unit conversions, date arithmetic, napkin math, and budgets.
---
# CalcMark Agent Skill

CalcMark is a calculation language that blends CommonMark markdown with inline calculations -- budgets, capacity plans, cost models, project estimates. Think "spreadsheet meets markdown."

Full reference: https://calcmark.org/docs/agent-integration/

## Installation

```bash
cm version  # check if installed
brew install calcmark/tap/calcmark  # macOS / Linux
```

## Syntax

```calcmark
price = $100                                          # currency
total = price * 12                                    # arithmetic
marked_up = price + 15%                               # percentage widening
marathon = 42.195 km in miles                         # unit conversion
€4500 in USD                                          # currency conversion (needs exchange frontmatter)
deadline = Jun 30 2026                                # dates
remaining = deadline - today                          # date arithmetic
2 weeks from today                                    # relative dates
api_rate = 1200 req/s                                 # rates
daily_requests = api_rate over 1 day                  # rate accumulation
1200 req/s per minute                                 # rate conversion (NL)
servers = 50000 req/s at 2000 req/s per server        # capacity planning
compound $10000 by 7% monthly over 30 years           # compound growth
depreciate $50000 by 15% over 5 years                 # depreciation
grow $500 by $100 over 36                             # linear growth
read 100 MB from ssd                                  # storage I/O
compress 1 GB using gzip                              # compression time
transfer 500 KB across regional gigabit               # network transfer
average of $100, $200, $300                           # aggregation
1234567 as napkin                                     # napkin math (~1.2M)
10K   5M   2B   1.5T                                  # multiplier suffixes
```

### Smart Type Handling

- `$49 * 2500 customers` → `$122,500.00` (currency * quantity = currency)
- `$100 + 15%` → `$115.00` (percentage widening)
- Use `number()` only for dimensionless ratios: `number(ltv) / number(cac)`

### Frontmatter

```yaml
---
title: Budget Analysis
locale: en-US
globals:
  tax_rate: 0.32
exchange:
  USD_EUR: 0.92
  EUR_USD: 1.09
---
```

Reference globals: `tax = income * @globals.tax_rate`

### Template Interpolation

Embed results in prose: `The project costs {{total_cost}}.`

## CLI Patterns

```bash
echo "compound $10000 by 7% over 30 years" | cm --format json   # one-liner
cm eval budget.cm --format json                                   # file
cm convert report.cm --to=html -o report.html                     # HTML output
cm help functions                                                 # runtime discovery
```

## Workflow Patterns

1. **Quick calc**: pipe one-liner, extract `numeric_value` from JSON
2. **Research artifact**: write `.cm` file, `cm eval` for JSON evidence
3. **Document deliverable**: write `.cm` with `{{templates}}`, `cm convert --to=html`

## JSON Output

Array of blocks (`"calculation"` or `"text"`). Each calculation result has: `source`, `value`, `type`, `numeric_value`, `variable`, `unit`.

**Errors** go to stderr (not JSON). Check exit code.
**Silent misinterpretation**: if output has `"type": "text"` where you expected calculations, the expression was treated as prose.

## Common Pitfalls

### Variables Are Immutable

Variables cannot be reassigned within a document. This will error:

```calcmark
x = 10
x = 20   # ERROR: cannot reassign 'x'
```

Use distinct variable names for each calculation step.

### Unit Propagation

Arithmetic preserves the numerator's unit. Raw division can produce unexpected units:

```calcmark
customers = 343 customers
servers_raw = customers / 10   # Result: 34.3 customers (NOT servers!)
```

Use the NL `capacity` form instead:

```calcmark
servers = 343 customers at 10 customers per server   # Result: 35 server ✓
```

### Prefer NL Forms Over Raw Arithmetic

Built-in NL functions handle rounding, units, and edge cases. Run `cm help functions` to see all available forms. Key examples:

- **Capacity**: `demand at cap per unit` instead of manual division
- **Growth**: `compound P by R over T` or `grow S by X over N` instead of manual formulas
- **Rates**: `rate over duration` instead of manual multiplication

### Error Output Goes to stderr

Errors are plain text on stderr, not JSON. Always check the exit code before parsing output as JSON.

## Security

- Ask the user before installing `cm`
- Write `.cm` files only in the project directory or temp directory
