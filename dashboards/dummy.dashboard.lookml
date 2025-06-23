---
- dashboard: Thomson_Reuters_DLP
  title: Governance Overview (Thomson Reuters)
  layout: newspaper
  crossfilter_enabled: true
  description: ''
  filters_location_top: false
  preferred_slug: NEPmcg1Q8xVsb5Njw8ugKR
  elements:
  - title: Total Unattested Tables (by usage)
    name: Total Unattested Tables (by usage)
    model: internal_framework
    explore: dlp_results
    type: looker_grid
    fields: [dlp_results.table_name, dlp_results.queries, dlp_results.data_owner,
      dlp_results.data_steward, dlp_results.Domain, dlp_results.risk_score]
    filters:
      dlp_results.attestation_flag: 'No'
    sorts: [queries desc]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: round(((rand()*(100-1+1))+1),0)
      label: random number
      value_format:
      value_format_name:
      _kind_hint: dimension
      table_calculation: random_number
      _type_hint: number
    - category: table_calculation
      expression: coalesce(${dlp_results.queries},${random_number})
      label: "# Queries"
      value_format:
      value_format_name:
      _kind_hint: dimension
      table_calculation: queries
      _type_hint: number
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag_2
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.pii
      expression: ''
      label: Count of PII
      measure: count_of_pii
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag_3
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.unprotected_column_flag
      expression: ''
      label: Count of Unprotected Column Flag (Yes / No)
      measure: count_of_unprotected_column_flag_yes_no
      type: count_distinct
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_labels:
      dlp_results.risk_score: "# High Risk (1-3)"
    series_column_widths:
      dlp_results.table_name: 428.3499999999999
    series_cell_visualizations:
      dlp_results.risk_score:
        is_active: true
        palette:
          palette_id: 25ed9327-c1c8-d891-0413-29c08c8d4092
          collection_id: badal
          custom_colors:
          - "#FFFFFF"
          - "#FF6961"
          - "#FF6961"
      queries:
        is_active: false
    series_text_format:
      dlp_results.risk_score:
        fg_color: "#FD9B80"
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [dlp_results.queries, random_number]
    listen:
      Domain: dlp_results.Domain
    row: 12
    col: 0
    width: 24
    height: 5
  - title: Top Unattested Info Type's
    name: Top Unattested Info Type's
    model: internal_framework
    explore: dlp_results
    type: looker_grid
    fields: [dlp_results.pii, dlp_results.data_owner, dlp_results.data_steward, dlp_results.Domain,
      count_of_table_name, count_of_column_name]
    sorts: [count_of_column_name desc]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag_2
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.pii
      expression: ''
      label: Count of PII
      measure: count_of_pii
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag_3
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.unprotected_column_flag
      expression: ''
      label: Count of Unprotected Column Flag (Yes / No)
      measure: count_of_unprotected_column_flag_yes_no
      type: count_distinct
    - category: measure
      expression: ''
      label: Count of Table Name
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: count_of_table_name
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.attestation_flag: 'No'
    - category: measure
      expression: ''
      label: Count of Column Name
      based_on: dlp_results.column_name
      _kind_hint: measure
      measure: count_of_column_name
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.attestation_flag: 'No'
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_labels:
      dlp_results.risk_score: "# High Risk (1-3)"
      count_of_table_name: Number of Tables
      count_of_column_name: Occurences
      dlp_results.pii: Info Type
    series_cell_visualizations:
      dlp_results.risk_score:
        is_active: true
        palette:
          palette_id: 5b988f3e-acb3-36b3-4b4f-0f781fcb77f0
          collection_id: badal
          custom_colors:
          - "#FFFFFF"
          - "#FF6961"
      queries:
        is_active: false
      count_of_table_name:
        is_active: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Domain: dlp_results.Domain
    row: 17
    col: 0
    width: 24
    height: 5
  - title: Top Unattested Tables (by Usage) by Domain
    name: Top Unattested Tables (by Usage) by Domain
    model: internal_framework
    explore: dlp_results
    type: looker_grid
    fields: [dlp_results.Domain, dlp_results.data_owner, count_of_table_name, count_of_column_name,
      dlp_results.data_steward]
    sorts: [count_of_column_name desc, count_of_table_name desc]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag_2
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.pii
      expression: ''
      label: Count of PII
      measure: count_of_pii
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.policy_tag
      expression: ''
      label: Count of Policy Tag
      measure: count_of_policy_tag_3
      type: count_distinct
    - _kind_hint: measure
      _type_hint: number
      based_on: dlp_results.unprotected_column_flag
      expression: ''
      label: Count of Unprotected Column Flag (Yes / No)
      measure: count_of_unprotected_column_flag_yes_no
      type: count_distinct
    - category: measure
      expression: ''
      label: Count of Table Name
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: count_of_table_name
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.attestation_flag: 'No'
    - category: measure
      expression: ''
      label: Count of Column Name
      based_on: dlp_results.column_name
      _kind_hint: measure
      measure: count_of_column_name
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.sensitivity_score: '"SENSITIVITY_LOW","SENSITIVITY_MODERATE","SENSITIVITY_HIGH"'
        dlp_results.attestation_flag: 'No'
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_labels:
      dlp_results.risk_score: "# High Risk (1-3)"
      count_of_table_name: "# Unattested Tables"
      count_of_column_name: "# Unattested Sensitive Columns"
    series_cell_visualizations:
      dlp_results.risk_score:
        is_active: true
        palette:
          palette_id: 5b988f3e-acb3-36b3-4b4f-0f781fcb77f0
          collection_id: badal
          custom_colors:
          - "#FFFFFF"
          - "#FF6961"
      queries:
        is_active: false
      count_of_table_name:
        is_active: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Domain: dlp_results.Domain
    row: 22
    col: 0
    width: 24
    height: 5
  - title: Overview1
    name: Overview1
    model: internal_framework
    explore: dlp_results
    type: marketplace_viz_multiple_value::multiple_value-marketplace
    fields: [high_risk_unattested_tables, tables_1, total_unattested_tables, tables_2,
      unattested_columns, columns]
    sorts: [high_risk_unattested_tables desc]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: measure
      expression: ''
      label: "# Tables"
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: tables
      type: count_distinct
      _type_hint: number
    - category: measure
      expression:
      label: "# Total Unattested Tables"
      value_format:
      value_format_name:
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: total_unattested_tables
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.attestation_flag: 'No'
    - category: measure
      expression:
      label: "# High Risk Unattested Tables"
      value_format:
      value_format_name:
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: high_risk_unattested_tables
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.attestation_flag: 'No'
        dlp_results.high_risk_table_flag: 'Yes'
    - category: measure
      expression:
      label: "# Unattested Columns"
      value_format:
      value_format_name:
      based_on: dlp_results.column_name
      _kind_hint: measure
      measure: unattested_columns
      type: count_distinct
      _type_hint: number
      filters:
        dlp_results.attestation_flag: 'No'
    - category: measure
      expression:
      label: Tables
      value_format:
      value_format_name:
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: tables_1
      type: count_distinct
      _type_hint: number
    - category: measure
      expression:
      label: Tables
      value_format:
      value_format_name:
      based_on: dlp_results.table_name
      _kind_hint: measure
      measure: tables_2
      type: count_distinct
      _type_hint: number
    - category: measure
      expression:
      label: Columns
      value_format:
      value_format_name:
      based_on: dlp_results.column_name
      _kind_hint: measure
      measure: columns
      type: count_distinct
      _type_hint: number
    hidden_fields: []
    hidden_points_if_no: []
    series_labels: {}
    show_view_names: true
    font_size_main: '20'
    orientation: auto
    style_tables: "#211B41"
    show_title_tables: true
    title_placement_tables: above
    value_format_tables: ''
    title_placement_high_risk_unattested_tables: above
    show_comparison_high_risk_unattested_tables: false
    show_comparison_tables_1: true
    comparison_style_tables_1: calculate_progress_perc
    comparison_show_label_tables_1: true
    comparison_label_placement_tables_1: below
    title_placement_total_unattested_tables: above
    show_comparison_total_unattested_tables: false
    show_comparison_tables_2: true
    comparison_style_tables_2: calculate_progress_perc
    comparison_show_label_tables_2: true
    comparison_label_placement_tables_2: below
    title_placement_unattested_columns: above
    show_comparison_columns: true
    comparison_style_columns: calculate_progress_perc
    comparison_show_label_columns: true
    comparison_label_placement_columns: below
    show_comparison_number_tables: true
    comparison_style_number_tables: calculate_progress_perc
    show_comparison_number_tables_copy: true
    comparison_style_number_tables_copy: calculate_progress_perc
    style_potential_unprotected_columns: "#3A4245"
    show_title_potential_unprotected_columns: true
    title_override_potential_unprotected_columns: "# Unattested Columns"
    title_placement_potential_unprotected_columns: above
    value_format_potential_unprotected_columns: ''
    show_comparison_potential_unprotected_columns: false
    comparison_style_total_unattested_tables: percentage_change
    style_high_risk_unclassified_tables: "#3A4245"
    show_title_high_risk_unclassified_tables: true
    title_placement_high_risk_unclassified_tables: above
    value_format_high_risk_unclassified_tables: ''
    style_unclassified_tables: "#3A4245"
    show_title_unclassified_tables: true
    title_placement_unclassified_tables: above
    value_format_unclassified_tables: ''
    show_comparison_unclassified_tables: false
    show_comparison_tables: false
    style_count_of_table_name: "#f49c84"
    show_title_count_of_table_name: true
    title_override_count_of_table_name: "# of Tables"
    title_placement_count_of_table_name: above
    value_format_count_of_table_name: ''
    style_dlp_results.count_scan_ids: "#f49c84"
    show_title_dlp_results.count_scan_ids: true
    title_override_dlp_results.count_scan_ids: "# of Scans"
    title_placement_dlp_results.count_scan_ids: above
    value_format_dlp_results.count_scan_ids: ''
    show_comparison_dlp_results.count_scan_ids: false
    style_dlp_results.count_pii: "#f49c84"
    show_title_dlp_results.count_pii: true
    title_override_dlp_results.count_pii: "# of PII Info Types"
    title_placement_dlp_results.count_pii: above
    value_format_dlp_results.count_pii: ''
    show_comparison_dlp_results.count_pii: false
    style_dlp_results.count_pii_column: "#f49c84"
    show_title_dlp_results.count_pii_column: true
    title_placement_dlp_results.count_pii_column: above
    value_format_dlp_results.count_pii_column: ''
    show_comparison_dlp_results.count_pii_column: false
    style_dlp_results.count: "#f49c84"
    show_title_dlp_results.count: true
    title_override_dlp_results.count: "# of Matches"
    title_placement_dlp_results.count: above
    value_format_dlp_results.count: ''
    show_comparison_dlp_results.count: false
    custom_color_enabled: true
    custom_color: "#947c9c"
    show_single_value_title: true
    single_value_title: "# of PII and Column Combinations"
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 0
    hidden_pivots: {}
    title_hidden: true
    listen:
      Domain: dlp_results.Domain
    row: 0
    col: 0
    width: 24
    height: 5
  - title: Sensitivity
    name: Sensitivity
    model: internal_framework
    explore: dlp_results
    type: looker_pie
    fields: [dlp_results.dynamic_metric, dlp_results.sensitivity_score]
    filters: {}
    sorts: [dlp_results.dynamic_metric desc 0]
    limit: 10
    column_limit: 50
    value_labels: labels
    label_type: labPer
    color_application:
      collection_id: badal
      palette_id: badal-categorical-0
      options:
        steps: 5
    series_colors: {}
    defaults_version: 1
    hidden_pivots: {}
    listen:
      Domain: dlp_results.Domain
    row: 5
    col: 16
    width: 8
    height: 7
  - title: Likelihood
    name: Likelihood
    model: internal_framework
    explore: dlp_results
    type: looker_pie
    fields: [dlp_results.likelihood, dlp_results.dynamic_metric]
    filters: {}
    sorts: [dlp_results.dynamic_metric desc 0]
    limit: 10
    column_limit: 50
    value_labels: labels
    label_type: labPer
    color_application:
      collection_id: 9d1da669-a6b4-4a4f-8519-3ea8723b79b5
      palette_id: 0c5264fb-0681-4817-b9a5-d3c81002ce4c
      options:
        steps: 5
    series_colors: {}
    defaults_version: 1
    hidden_pivots: {}
    listen:
      Domain: dlp_results.Domain
    row: 5
    col: 8
    width: 8
    height: 7
  - title: Top 5 Info Type's
    name: Top 5 Info Type's
    model: internal_framework
    explore: dlp_results
    type: looker_pie
    fields: [dlp_results.pii, dlp_results.dynamic_metric]
    sorts: [dlp_results.dynamic_metric desc 0]
    limit: 5
    column_limit: 50
    value_labels: labels
    label_type: labPer
    color_application:
      collection_id: scotia
      palette_id: scotia-categorical-0
      options:
        steps: 5
    defaults_version: 1
    hidden_pivots: {}
    listen:
      Domain: dlp_results.Domain
    row: 5
    col: 0
    width: 8
    height: 7
  filters:
  - name: Domain
    title: Domain
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: internal_framework
    explore: dlp_results
    listens_to_filters: []
    field: dlp_results.Domain
