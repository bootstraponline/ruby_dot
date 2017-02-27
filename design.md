Design notes.

#### Overview

- Parser gem walks the AST and extracts fully qualified module/class names
- Mustache renders draw.io compatible XML
- `draw.io` → `File` → `Import from` → `Device...` then select `class_map.rb.xml`

#### Details

- [Replaced legacy processor with new before/after design](https://github.com/bootstraponline/ruby_dot/commit/516b3f774b41bfc7b146ff31f5f212717854318f)
