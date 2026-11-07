# Spec Delta

## MODIFIED Requirements

### Requirement: Help lists the option

`--help` SHALL list `--stdout` in the "Options" section right after `--skip-no-markers`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after
  `  --skip-no-markers   Skip files without <!--ts--> or <!--te-->. Set --insert as well. Default: false.`
  is
  `  --stdout            Print the whole file with the new TOC to stdout. The file is not changed. Default: false.`
