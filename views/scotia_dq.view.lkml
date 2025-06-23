
view: scotia_dq {
  # sql_table_name: prj-s-dlp-dq-sandbox-0b3c.dbt_tchopra.dqim_test_data ;;
  derived_table: {
    sql:
              with cte as (
                            select distinct ETL_Process_Date
                              ,case when (format_date("%A", ETL_Process_Date) = "Wednesday")
                                              and
                                          (ETL_Process_Date not in ('2020-09-30'
                                          ,'2021-03-31','2021-06-30', '2022-08-31'))
                                          then (TIMESTAMP(ETL_Process_Date)) end as Weekly_ETL_Process_Date


      ,case when (ETL_Process_Date = date_trunc(ETL_Process_Date, month))
      and
      (date_diff(current_date(),ETL_Process_Date,month) >= 0)
      then TIMESTAMP(DATETIME_SUB(DATETIME ((TIMESTAMP(ETL_Process_Date))),INTERVAL 1 DAY))
      end as Monthly_ETL_Process_Date

      from `@{data_quality_table}`
      ),

      weekly as (
      select Weekly_ETL_Process_Date
      ,row_number() over (order by Weekly_ETL_Process_Date desc) as Weekly_Rank
      from cte
      ),

      monthly as (
      select Monthly_ETL_Process_Date
      ,row_number() over (order by Monthly_ETL_Process_Date desc) as Monthly_Rank
      from cte
      ),

      rank_query as (
      select
      a.ETL_Process_Date
      ,a.Weekly_ETL_Process_Date
      ,b.Weekly_Rank
      ,a.Monthly_ETL_Process_Date
      ,c.Monthly_Rank
      from cte as a
      left join weekly as b
      on a.Weekly_ETL_Process_Date = b.Weekly_ETL_Process_Date
      left join monthly as c
      on a.Monthly_ETL_Process_Date = c.Monthly_ETL_Process_Date
      )

      select a.*
      ,b.Weekly_ETL_Process_Date
      ,b.Weekly_Rank
      ,b.Monthly_ETL_Process_Date
      ,b.Monthly_Rank
      from `@{data_quality_table}` as a
      left join rank_query as b
      on a.etl_process_date = b.ETL_Process_Date;;
  }

################################################ PARAMETERS ################################################

  parameter: View_Type {
    type: string
    default_value: "Closed & Cancelled"
    allowed_value: {
      value: "Closed & Cancelled"
    }
    allowed_value: {
      value: "Resolved"
    }
  }

  parameter: Cancelled_vs_closed_sort {
    type: string
    label: "Cancelled vs Closed Sort"
    default_value: "1"
    allowed_value: {
      value: "1"
      label: "Closed"
    }
    allowed_value: {
      value: "2"
      label: "Cancelled"
    }
  }

  parameter: Open_Deferred_Swap {
    type: string
    label: "Open / Deferred Swap"
    default_value: "Open Issues w/o Deferred Issues"
    allowed_value: {
      value: "Open Issues w/o Deferred Issues"
    }
    allowed_value: {
      value: "Deferred Issues"
    }
  }

  parameter: Aging_Aggregation_Type{
    type: string
    label: "Aging Aggregation Type"
    default_value: "Aging by Status"
    allowed_value: {
      value: "Aging by Status"
    }
    allowed_value: {
      value: "Cumulative Aging"
    }
  }

  parameter: Consumer_Producer{
    type: string
    label: "Consumer / Producer"
    default_value: "Consumer"
    allowed_value: {
      value: "Consumer"
    }
    allowed_value: {
      value: "Producer"
    }
  }

  parameter: Frequency{
    type: string
    label: "Frequency"
    default_value: "Weekly"
    allowed_value: {
      value: "Weekly"
    }
    allowed_value: {
      value: "Monthly"
    }
  }

  parameter: RCA_VS_Remediation{
    type: string
    label: "RCA vs. Remediation"
    default_value: "RCA"
    allowed_value: {
      value: "RCA"
    }
    allowed_value: {
      value: "Remediation"
    }
  }

  parameter: Serverity_Priority_Swap{
    type: string
    label: "Severity / Priority Swap"
    default_value: "Severity"
    allowed_value: {
      value: "Severity"
    }
    allowed_value: {
      value: "Priority"
    }
  }

  parameter: Trend_View{
    type: string
    label: "Trend View"
    default_value: "Last 12 Months"
    allowed_value: {
      value: "Last 12 Months"
    }
    allowed_value: {
      value: "Entire History"
    }
  }

  parameter: Date_Ranges{
    type: unquoted
    label: "Date Ranges"
    default_value: "12"
    allowed_value: {
      value: "12"
      label: "Last 12 Periods"
    }
    allowed_value: {
      value: "24"
      label: "Last 24 Periods"
    }
    allowed_value: {
      value: "36"
      label: "Last 36 Periods"
    }
    allowed_value: {
      value: "1000"
      label: "Since Inception"
    }
  }
################################################ DIMENSIONS FROM DERIVED TABLE ################################################

  dimension: actual_rca_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Actual_Rca_Date ;;
  }

  dimension: actual_remd_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Actual_Remd_Date ;;
  }

  dimension: data_element {
    type: string
    sql: ${TABLE}.Data_Element ;;
  }

  dimension: data_source {
    type: string
    sql: ${TABLE}.Data_Source ;;
  }

  dimension: deferred_start_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Deferred_Start_Date ;;
  }

  dimension: dq_create_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.DQ_Create_Date ;;
  }

  dimension: dq_issue_id {
    type: string
    sql: ${TABLE}.DQ_Issue_ID ;;
  }

  dimension_group: etl_process_date_group {
    type: time
    label: "ETL Process Date"
    # datatype: date
    group_label: "Dates"
    timeframes: [time, date, raw]
    sql: TIMESTAMP(${TABLE}.ETL_Process_Date) ;;
  }

  # dimension_group: last_report_date_weekly {
  #   type: time
  #   #label: "ETL Process Date"
  #   # datatype: date
  #   group_label: "Dates"
  #   timeframes: [time, date, raw]
  #   sql: TIMESTAMP(${TABLE}.last_report_date_weekly) ;;
  # }

  # dimension_group: last_report_date_monthly {
  #   type: time
  #   #label: "ETL Process Date"
  #   # datatype: date
  #   group_label: "Dates"
  #   timeframes: [time, date, raw]
  #   sql: TIMESTAMP(${TABLE}.last_report_date_monthly) ;;
  # }

  # dimension: etl_process_date {
  #   type: date
  #   datatype: date
  #   group_label: "Dates"
  #   # timeframes: [time, date, raw]
  #   sql: ${TABLE}.ETL_Process_Date ;;
  # }

  dimension: investigator_domain {
    type: string
    sql: ${TABLE}.Investigator_Domain ;;
  }

  dimension: issue_champion {
    type: string
    sql: ${TABLE}.Issue_Champion ;;
  }

  dimension: issue_investigator {
    type: string
    sql: ${TABLE}.Issue_Investigator ;;
  }

  dimension: issue_reporter {
    type: string
    sql: ${TABLE}.Issue_Reporter ;;
  }

  dimension: issue_reporter_domain_old {
    type: string
    sql: ${TABLE}.Issue_Reporter_Domain_old ;;
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}.Issue_Type ;;
  }

  dimension: department_tenant {
    type: string
    label: "Department/Tenant"
    sql: ${issue_type} ;;
  }

  dimension: line_of_business {
    type: string
    sql: ${TABLE}.Line_Of_Business ;;
  }

  dimension: new_start_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.New_Start_Date ;;
  }

  dimension: past_deferred_start_date {
    type: string
    group_label: "Dates String"
    sql: ${TABLE}.Past_Deferred_Start_Date ;;
  }

  dimension: past_target_deferred_date {
    type: string
    group_label: "Dates String"
    sql: ${TABLE}.Past_Target_Deferred_Date ;;
  }

  dimension: past_target_rca_date {
    type: string
    group_label: "Dates String"
    sql: ${TABLE}.Past_Target_Rca_Date ;;
  }

  dimension: past_target_remed_date {
    type: string
    group_label: "Dates String"
    sql: ${TABLE}.Past_Target_Remed_Date ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}.Priority ;;
  }

  dimension: rca_start_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Rca_Start_Date ;;
  }

  dimension: resolver {
    type: string
    sql: ${TABLE}.Resolver ;;
  }

  dimension: resolving_domain {
    type: string
    sql: ${TABLE}.Resolving_Domain ;;
  }

  dimension: severity {
    type: string
    sql: ${TABLE}.Severity ;;
  }

  dimension: sourced_from {
    type: string
    sql: ${TABLE}.Sourced_From ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.Status ;;
  }

  dimension: target_deferred_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Target_Deferred_Date ;;
  }

  dimension: target_remd_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Target_Remd_Date ;;
  }

  dimension: target_root_cause_analysis_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Target_Root_Cause_Analysis_Date ;;
  }

  dimension: updated_timestamp_on {
    type: string
    sql: ${TABLE}.Updated_Timestamp_On ;;
  }

  dimension: verification_date {
    type: date
    datatype: date
    group_label: "Dates"
    sql: ${TABLE}.Verification_Date ;;
  }

################################################ DIMENSIONS W/LOGIC ################################################

  dimension: Full_Name {
    type: string
    sql: '{{ _user_attributes['name'] }}' ;;
  }

  # dimension: last_report_date {
  #   type: date
  #   group_label: "Dates"
  #   sql: {% if Frequency._parameter_value == "'Weekly'" %}
  #                     ${last_report_date_weekly_raw}
  #                     {% else %}
  #                     ${last_report_date_monthly_raw}
  #                     {% endif %} ;;
  # }

  dimension: System_Manual_Issue {
    type: string
    label: "System/Manual Issue"
    sql: case when ${issue_reporter} in ("SYSTEM", "System - Others") then "Auto DQ" else "Manual DQ" end ;;
  }

  dimension: Issue_Reporter_Domain_domain {
    type: string
    label: "Issue Reporter Domain (Domains)"
    sql: case when ${issue_reporter_domain_old} = "Enterprise Data Quality" then "Enterprise Data Quality"
              when ${issue_reporter_domain_old} = "AML Name Screening (sub-domain)" then "Enterprise - Name Screening (sub-domain)"
              when ${issue_reporter_domain_old} = "AML Regulatory Reporting (sub-domain)" then "Enterprise - AMl Regulatory Reporting (sub-domain)"
              when ${issue_reporter_domain_old} = "AML Transaction Monitoring (sub-domain)" then "Enterprise - AMl Transaction Monitoring (sub-domain)"
              when ${issue_reporter_domain_old} = "Anti Money Laundering" then "Enterprise - Anti Money Laundering"
              when ${issue_reporter_domain_old} = "Capital Reporting" then "Enterprise - Finance Capital Reporting"
              when ${issue_reporter_domain_old} = "Counterparty Credit Risk" then "Enterprise - Counterparty Credit Risk"
              when ${issue_reporter_domain_old} = "Customer" then "Enterprise - Customer"
              when ${issue_reporter_domain_old} = "Global Sactions Screening" then "GBM - Global Sactions Screening"
              when ${issue_reporter_domain_old} = "Liquidity Risk" then "Enterprise - Liquidity Risk"
              when ${issue_reporter_domain_old} = "Market Risk" then "Enterprise - Market Risk"
              when ${issue_reporter_domain_old} = "Non-Retail Credit Risk" then "Enterprise - Business Banking Credit Risk"
              when ${issue_reporter_domain_old} = "Operational Risk" then "Enterprise - Operational Risk"
              when ${issue_reporter_domain_old} = "Retail Credit Risk" then "Enterprise - Retail Credit Risk"
              when ${issue_reporter_domain_old} = "Secured Interest Rate Risk" then "Enterprise - Secured Interest Rate Risk"
              when ${issue_reporter_domain_old} in ("US HR","US Human Resources") then "US Human Resources"
              when ${issue_reporter_domain_old} in ("COCU","Colombia Customer Individual") then "Colombia Customer Individal"
              when ${issue_reporter_domain_old} in ("AML Client Risk Rating (sub-domain)","AML Customer Risk Rating (sub-domain)")
                                                            then "Enterprise - AML Client Risk Rating (sub-domain)"
              else ${issue_reporter_domain_old} end;;
  }

  dimension: Ivestigator_Domain_group {
    type: string
    label: "Investigator Domain (group)"
    sql: case when ${investigator_domain} in ("US HR","US Human Resources") then "US Human Resources"
              when ${investigator_domain} = "AML Client Risk Rating (sub-domain)" then "Enterprise - AML Client Risk Rating (sub-domain)"
              when ${investigator_domain} = "AML Name Screening (sub-domain)" then "Enterprise - Name Screening (sub-domain)"
              when ${investigator_domain} = "AML Regulatory Reporting (sub-domain)" then "Enterprise - AMl Regulatory Reporting (sub-domain)"
              when ${investigator_domain} = "AML Transaction Monitoring (sub-domain)" then "Enterprise - AMl Transaction Monitoring (sub-domain)"
              when ${investigator_domain} = "Capital Reporting" then "Enterprise - Finance Capital Reporting"
              when ${investigator_domain} = "Counterparty Credit Risk" then "Enterprise - Counterparty Credit Risk"
              when ${investigator_domain} = "Customer" then "Enterprise - Customer"
              when ${investigator_domain} = "Global Sactions Screening" then "GBM - Global Sactions Screening"
              when ${investigator_domain} = "Liquidity Risk" then "Enterprise - Liquidity Risk"
              when ${investigator_domain} = "Market Risk" then "Enterprise - Market Risk"
              when ${investigator_domain} = "Operational Risk" then "Enterprise - Operational Risk"
              when ${investigator_domain} = "Retail Credit Risk" then "Enterprise - Retail Credit Risk"
              when ${investigator_domain} = "Structured Interest Rate Risk" then "Enterprise - Structured Interest Rate Risk"
              else ${investigator_domain} end ;;
  }

  dimension: Resolving_Domain_group {
    type: string
    label: "Resolving Domain (group)"
    sql: case when ${resolving_domain} in ("US HR","US Human Resources") then "US Human Resources"
              when ${resolving_domain} = "AML Client Risk Rating (sub-domain)" then "Enterprise - AML Client Risk Rating (sub-domain)"
              when ${resolving_domain} = "AML Name Screening (sub-domain)" then "Enterprise - Name Screening (sub-domain)"
              when ${resolving_domain} = "AML Regulatory Reporting (sub-domain)" then "Enterprise - AMl Regulatory Reporting (sub-domain)"
              when ${resolving_domain} = "AML Transaction Monitoring (sub-domain)" then "Enterprise - AMl Transaction Monitoring (sub-domain)"
              when ${resolving_domain} = "Capital Reporting" then "Enterprise - Finance Capital Reporting"
              when ${resolving_domain} = "Colombia Customer Individual" then "Colombia Customer Individal"
              when ${resolving_domain} = "Counterparty Credit Risk" then "Enterprise - Counterparty Credit Risk"
              when ${resolving_domain} = "Customer" then "Enterprise - Customer"
              when ${resolving_domain} = "Global Sactions Screening" then "GBM - Global Sactions Screening"
              when ${resolving_domain} = "Liquidity Risk" then "Enterprise - Liquidity Risk"
              when ${resolving_domain} = "Market Risk" then "Enterprise - Market Risk"
              when ${resolving_domain} = "Non-Retail Credit Risk" then "Enterprise - Business Banking Credit Risk"
              when ${resolving_domain} = "Operational Risk" then "Enterprise - Operational Risk"
              when ${resolving_domain} = "Retail Credit Risk" then "Enterprise - Retail Credit Risk"
              when ${resolving_domain} = "Structured Interest Rate Risk" then "Enterprise - Structured Interest Rate Risk"
              else ${resolving_domain} end ;;
  }

  dimension: Status_2_group_w_resolved{
    type: string
    label: "Status 2 (Group w/ resolved)"
    sql: case when ${status} in ("Closed", "Cancelled") then "Resolved"
              when ${status} in ("Remediation", "Reject Remediation", "Root Cause Analysis", "Verification") then "In Progress"
            else ${status} end ;;
            # else "works" end;; # this is just to test if the parameter works
    }

    dimension: status_group {
      type: string
      label: "Status (group)"
      sql: case when ${status} in ('Reject Remediation','Remediation') then "Remediation" else ${status} end ;;
    }

    dimension: status_2_group {
      type: string
      label: "Status 2 (group)"
      sql: case when ${status} in ('Reject Remediation','Remediation','Root Cause Analysis','Verification') then "In Progress" else ${status} end ;;
    }

    dimension: Closed_Cancelled_vs_Resolved{
      type: string
      label: "Closed/Cancelled vs. Resolved"
      sql: {% if View_Type._parameter_value == "'Resolved'" %}
                ${Status_2_group_w_resolved}
          {% else %}
                ${status}
          {% endif %} ;;
    }

    dimension: Aging_Bucket {
      type: string
      sql: case when ${Aging_dimension} <= 90 then "0-90 Days"
              when ${Aging_dimension} <= 180 then "91-180 Days"
              when ${Aging_dimension} <= 365 then "181-365 Days"
              else "365+ Days" end ;;
    }

    dimension: Aging_Bucket_Cumulative {
      type: string
      sql: case when ${Aging_Cumulative_dimension} <= 90 then "0-90 Days"
              when ${Aging_Cumulative_dimension} <= 180 then "91-180 Days"
              when ${Aging_Cumulative_dimension} <= 365 then "181-365 Days"
              else "365+ Days" end ;;
    }

    dimension: Aging_Bucket_Selection{
      type: string
      label: "Aging Bucket Selection"
      sql: {% if Aging_Aggregation_Type._parameter_value == "'Cumulative Aging'" %}
                ${Aging_Bucket_Cumulative}
          {% else %}
                ${Aging_Bucket}
          {% endif %} ;;
    }

    dimension: Combined_Status {
      type: string
      sql: case when ${status} in ('Closed','Cancelled') then 'Resolved Issues'
        else 'Open Issues' end ;;
      # sql: case when ${status} in ('DeleteEvent','CreateEvent') then 'Resolved Issues'
      #                 else 'Open Issues' end ;;
    }

    dimension: Separated_Status {
      type: string
      sql: case when ${status} in ('Closed','Cancelled') then concat(${status},' ','Issues')
        else 'Open Issues' end ;;
      # sql: case when ${status} in ('DeleteEvent','CreateEvent') then concat(${status},' ','Issues')
      #               else 'Open Issues' end ;;
    }

    dimension: Combined_Separated_Status {
      type: string
      label: "Combined/Separated Status"
      sql: {% if View_Type._parameter_value == "'Resolved'" %}
                              ${Combined_Status}
          {% else %}
                              ${Separated_Status}
          {% endif %} ;;
    }

    dimension: Consumer_Producer_Domain {
      type: string
      label: "Consumer/Producer Domain"
      sql:  {% if Consumer_Producer._parameter_value == "'Consumer'" %}
               case when ${status} = "New" and ((${Ivestigator_Domain_group} is not null) or (${Ivestigator_Domain_group} <> "")) then ${Ivestigator_Domain_group}
                    when ${status} = "Remediation" then ${Resolving_Domain_group}
                    when ${status} = "Root Cause Analysis" then ${Ivestigator_Domain_group}
                    else ${Issue_Reporter_Domain_domain} end
          {% else %}
                              ${Issue_Reporter_Domain_domain}
          {% endif %} ;;
    }

    dimension: Consumer_Producer_Domain_Filter {
      type: string
      label: "Consumer/Producer Domain Filter"
      sql:  {% if Consumer_Producer._parameter_value == "'Producer'" %}
               case when ${status} = "New" and ((${Ivestigator_Domain_group} is not null) or (${Ivestigator_Domain_group} <> "")) then ${Ivestigator_Domain_group}
                    when ${status} = "Remediation" then ${Resolving_Domain_group}
                    when ${status} = "Root Cause Analysis" then ${Ivestigator_Domain_group}
                    else ${Issue_Reporter_Domain_domain} end
          {% else %}
                              ${Issue_Reporter_Domain_domain}
          {% endif %} ;;
    }

    dimension: Deferred_Aging_Bucket {
      type: string
      sql: case when ${Deferred_Aging_dimension} <= 90 then "0-90 Days"
              when ${Deferred_Aging_dimension} <= 180 then "91-180 Days"
              when ${Deferred_Aging_dimension} <= 365 then "181-365 Days"
              else "365+ Days" end ;;
    }

    dimension: Deferred_Past_Due {
      type: string
      sql: case when ${target_deferred_date} < ${etl_process_date_group_date} then "Past Due"
        else FORMAT_DATE("%b-%y", ${target_deferred_date}) end ;;
    }

    dimension_group: w_m_snapshot_date_date_group {
      type: time
      label: "w/m snapshot date (date)"
      group_label: "Dates"
      timeframes: [day_of_month,month_name,year, date, raw]
      sql: case when ${etl_process_date_group_raw} < TIMESTAMP('2021-06-30') then (
                                    {% if Frequency._parameter_value == "'Monthly'" %}
                                                    case when (${etl_process_date_group_date} = last_day(${etl_process_date_group_date}, month))
                                                            and
                                                                (date_diff(current_date(),${etl_process_date_group_date},month) > 0)
                                                                then ${etl_process_date_group_raw} end
                                    {% else %}
                                                    case when (format_date("%A", ${etl_process_date_group_raw}) = "Wednesday")
                                                              and
                                                                          (${etl_process_date_group_raw} not in (TIMESTAMP('2020-09-30'),
                                                                          TIMESTAMP('2021-03-31'),
                                                                          TIMESTAMP('2021-06-30'),
                                                                          TIMESTAMP('2022-08-31')))
                                                    then ${etl_process_date_group_raw} end
                                    {% endif %}

        )

        else (
        {% if Frequency._parameter_value == "'Monthly'" %}
        case when (${etl_process_date_group_raw} = date_trunc(${etl_process_date_group_raw}, month))
        and
        (date_diff(current_date(),${etl_process_date_group_date},month) >= 0)
        then TIMESTAMP(DATETIME_SUB(DATETIME (${etl_process_date_group_raw}), INTERVAL 1 DAY)) end
        {% else %}
        case when (format_date("%A", ${etl_process_date_group_date}) = "Wednesday")
        and
        (${etl_process_date_group_raw} not in (TIMESTAMP('2020-09-30'),
        TIMESTAMP('2021-03-31'),
        TIMESTAMP('2021-06-30'),
        TIMESTAMP('2022-08-31')))
        then ${etl_process_date_group_raw} end
        {% endif %}
        )
        end;;
    }

    dimension: report_date {
      type: string
      sql:   {% if Frequency._parameter_value == "'Monthly'" %}
                    format_date("%b-%Y", ${w_m_snapshot_date_date_group_date})
          {% else %}
                    format_date("%b-%d-%Y", ${w_m_snapshot_date_date_group_date})
           {% endif %}
    ;;
      order_by_field: w_m_snapshot_date_date_group_date
    }



    dimension: weekly_rank {
      type: number
      hidden: yes
      sql: ${TABLE}.Weekly_Rank ;;
    }

    dimension: monthly_rank {
      type: number
      hidden: yes
      sql: ${TABLE}.Monthly_Rank ;;
    }

    dimension: w_m_snapshot_date_date_rank {
      type: number
      label: "w/m snapshot date (date) rank"
      group_label: "Dates Test"
      sql: {% if Frequency._parameter_value == "'Weekly'" %}
                      ${weekly_rank}
                      {% else %}
                      ${monthly_rank}
                      {% endif %} ;;
    }


    dimension: Date_Text {
      type: string
      group_label: "Dates"
      sql: concat(${w_m_snapshot_date_date_group_day_of_month},' ',${w_m_snapshot_date_date_group_month_name},' ',${w_m_snapshot_date_date_group_year}) ;;
    }

    dimension: w_m_snapshot_date_date_planning {
      type: date
      label: "w/m snapshot date (date) (planning)"
      group_label: "Dates"
      sql: case when format_date("%d", ${etl_process_date_group_date}) in ('01') and format_date("%A", ${etl_process_date_group_date}) <> "Thursday"
                    then TIMESTAMP(DATETIME_SUB(DATETIME (${etl_process_date_group_raw}), INTERVAL 1 DAY))
              when format_date("%A", ${etl_process_date_group_date}) = "Wednesday" and ${etl_process_date_group_date} <> '2020-09-30'
                    then ${etl_process_date_group_raw}
                        else null end ;;
    }

    dimension: w_m_snapshot_date_formatting {
      type: string
      label: "w/m snapshot date formatting"
      group_label: "Dates String"
      sql:{% if Frequency._parameter_value == "'Monthly'" %}
            case when DATE_DIFF(current_date(), ${etl_process_date_group_date}, MONTH) >=0
                 then FORMAT_DATE('%b', ${etl_process_date_group_date}-1) || " '" || FORMAT_DATE('%g', ${etl_process_date_group_date}-1)
                 when DATE_DIFF(current_date(), ${etl_process_date_group_date}, MONTH) >0
                 then FORMAT_DATE('%b', ${etl_process_date_group_date}) || " '" || FORMAT_DATE('%g', ${etl_process_date_group_date})
            end
            {% elsif Frequency._parameter_value == "'Weekly'" %}
            case when ${etl_process_date_group_date} ='2020-02-28' and ${issue_reporter_domain_old} <> "AML Name Screening (sub-domain)"
                 then FORMAT_DATE('%D', ${etl_process_date_group_date})
                 when ${etl_process_date_group_date}<>'2020-02-28'
                 then FORMAT_DATE('%D', ${etl_process_date_group_date})
            end
            {% else %}
              null
            {% endif %};;
    }

    dimension: w_m_snapshot_date_formatting_monthly {
      type: string
      label: "w/m snapshot date formatting Monthly"
      group_label: "Dates String"
      sql:{% if Frequency._parameter_value == "'Monthly'" %}
            case when ${etl_process_date_group_date}<'2021-06-30' AND DATE_DIFF(current_date(), ${etl_process_date_group_date}, MONTH)>0
                 then FORMAT_DATE('%b', ${etl_process_date_group_date}) || " '" || FORMAT_DATE('%g', ${etl_process_date_group_date})
                 when DATE_DIFF(current_date(), ${etl_process_date_group_date}, MONTH)>=0 and FORMAT_DATE('%m', ${etl_process_date_group_date})='01'
                 then FORMAT_DATE('%b', ${etl_process_date_group_date}-1) || " '" || FORMAT_DATE('%g', ${etl_process_date_group_date}-30)
                 when DATE_DIFF(current_date(), ${etl_process_date_group_date}, MONTH)>=0
                 then FORMAT_DATE('%b', ${etl_process_date_group_date}-1) || " '" || FORMAT_DATE('%g', ${etl_process_date_group_date})
            end
            {% else %}
              null
            {% endif %};;
    }

    dimension: w_m_snapshot_date_formatting_weekly {
      type: string
      label: "w/m snapshot date formatting Weekly"
      group_label: "Dates String"
      sql:{% if Frequency._parameter_value == "'Weekly'" %}
            case when ${etl_process_date_group_date} ='2020-02-28' and ${issue_reporter_domain_old} <> "AML Name Screening (sub-domain)"
                 then FORMAT_DATE('%D', ${etl_process_date_group_date})
                 when ${etl_process_date_group_date}<>'2020-02-28'
                 then FORMAT_DATE('%D', ${etl_process_date_group_date})
            end
            {% else %}
              null
            {% endif %};;
    }

    dimension: w_m_snapshot_date_formatting_dynamic {
      type: string
      label: "w/m snapshot date formatting dynamic"
      group_label: "Dates String"
      sql: {% if Frequency._parameter_value == "'Weekly'" %}
                  ${w_m_snapshot_date_formatting_weekly}
          {% else %}
                  ${w_m_snapshot_date_formatting_monthly}
          {% endif %};;
    }

    dimension: Weekly {
      type: yesno
      sql:  format_date("%A", ${etl_process_date_group_date}) = "Wednesday";;
    }

    dimension: Monthly {
      type: yesno
      sql:  case when  ${etl_process_date_group_date} < '2021-06-30' and (${etl_process_date_group_date} = last_day(${etl_process_date_group_date}, month)) then true
              when  ${etl_process_date_group_date} >= '2021-06-30'and (${etl_process_date_group_date} = date_trunc(${etl_process_date_group_date}, month))  then true
              else false end;;
    }

    dimension: WoW_MoM {
      type: yesno
      label: "WoW/MoM"
      sql:   {% if Frequency._parameter_value == "'Monthly'" %}
                      ${Monthly}
                      {% else %}
                      ${Weekly}
                      {% endif %} ;;
    }

    dimension: Month_End_Wednesday {
      type: yesno
      group_label: "Dates"
      sql:  (format_date("%A", ${etl_process_date_group_date}) = "Wednesday") or (${etl_process_date_group_date} = ${w_m_snapshot_date_date_planning}+1) ;;
    }

    dimension: Domain {
      type: string
      sql:   {% if RCA_VS_Remediation._parameter_value == "'RCA'" %}
                              ${investigator_domain}
          {% else %}
                              ${resolving_domain}
          {% endif %} ;;
    }

    dimension: Domain_Groups {
      type: string
      description: "pulls from resolving domain group"
      sql: case when ${Resolving_Domain_group} in ('Enterprise - AML Client Risk Rating (sub-domain)','Enterprise - Name Screening (sub-domain)'
                                              ,'Enterprise - AMl Regulatory Reporting (sub-domain)','Enterprise - AMl Transaction Monitoring (sub-domain)')
                                              then 'Enterprise AML'
              when ${Resolving_Domain_group} in ("Enterprise - Counterparty Credit Risk", "Enterprise - Customer", "Enterprise - Liquidity Risk",
                                                "Enterprise - Market Risk", "Enterprise - Operational Risk","Enterprise - Retail Credit Risk"
                                                ,"Enterprise - Structured Interest Rate Risk","Enterprise - Business Banking Credit Risk")
                                              then 'Enterprise Risk'
              when ${Resolving_Domain_group} in ('Bahamas and Turks & Caicos Finance Regulatory Reporting','Barbados Finance Regualtory Reporting'
                                                          ,'Cayman Islands Finance Regulatory Reporting','Colombia Finance Regulatory Reporting'
                                                          ,'Dominican Republic Finance Regulatory Reporting','Enterprise - Finance Capital Reporting'
                                                          ,'Finance - GBM - Scotia Capital Inc','Financial Accounting and Reporting - Regulatory Reporting'
                                                          ,'Jamaica Finance Regulatory Reporting','Mexico Finance Regulatory Reporting', 'Panama Finance Regulatory Reporting'
                                                          ,'Peru FInance Regulatory Reproting', 'US Finance')
                                              then 'Global Finance'
                              else 'Other' end;;
    }

    ##################################################### DIMENIONS THAT JUST PRINT TEXT #########################


    dimension: Foot_Note_Aging_View {
      type: string
      group_label: "Only Printed Strings"
      sql: "*Cumulative Aging is evaluated after the issue has moved to the New status" ;;
    }

    dimension: Detail_Report {
      type: string
      group_label: "Only Printed Strings"
      sql: "Detail Report" ;;
    }

    dimension: Title_number_of_times_reforecasted {
      type: string
      group_label: "Only Printed Strings"
      label: "Title - # of times Reforecasted"
      sql: "# Times Reforecasted" ;;
    }

    dimension: Title_Aging_View_1 {
      type: string
      group_label: "Only Printed Strings"
      sql:  {% if Open_Deferred_Swap._parameter_value == "'Open Issues w/o Deferred Issues'"%}
                                    "Current Status by Aging"
                        {% else %}
                                    "Deferred Issues Aging"
                        {%  endif %} ;;
    }

    dimension: Title_Aging_View_2 {
      type: string
      group_label: "Only Printed Strings"
      sql:  {% if Open_Deferred_Swap._parameter_value == "'Open Issues w/o Deferred Issues'"%}
                                    "Issue Status by Severity"
                        {% else %}
                                    "Deferred Issues by Severity"
                        {%  endif %} ;;
    }

    dimension: Title_Aging_View_3 {
      type: string
      group_label: "Only Printed Strings"
      sql:  {% if Open_Deferred_Swap._parameter_value == "'Open Issues w/o Deferred Issues'"%}
                                    "Current Status Aging - Automated"
                        {% else %}
                                    "Deferred Issues by Domain"
                        {%  endif %} ;;
    }

    dimension: Title_Aging_View_4 {
      type: string
      group_label: "Only Printed Strings"
      sql:  {% if Open_Deferred_Swap._parameter_value == "'Open Issues w/o Deferred Issues'"%}
                                    "Current Status Aging - Self Identified"
                        {% else %}
                                    "Deferred Issues by Investigator"
                        {%  endif %} ;;
    }

    dimension: Title_Combined_Separated {
      type: string
      group_label: "Only Printed Strings"
      label: "Title Combined/Separated"
      sql:  {% if View_Type._parameter_value == "'Resolved'"%}
                                    "Resolved Issues by Domain"
                        {% else %}
                                    "Closed & Cancelled Issues by Domain"
                        {%  endif %} ;;
    }

    dimension: Consumer_Producer_Domain_for_Title {
      type: string
      label: "Consumer/Producer Domain for Title"
      group_label: "Only Printed Strings"
      sql: {% if Consumer_Producer._parameter_value == "'Consumer'" %}
                                            "Producer"
                        {% else %}
                                            "Consumer"
                        {% endif %} ;;
    }

    dimension: Weekly_View {
      type: string
      group_label: "Only Printed Strings"
      sql: {% if Frequency._parameter_value == "'Weekly'" %}
                                            "true"
                           {% else %}
                                            "false"
                        {% endif %} ;;
    }

    dimension: Percent_Change_Text {
      type: string
      group_label: "Only Printed Strings"
      sql:  {% if Frequency._parameter_value == "'Weekly'"%}
                                    "Week over Week"
                        {% else %}
                                    "Month over Month"
                        {%  endif %} ;;
    }

    dimension: Show_Hide_Foot_Note {
      type: string
      group_label: "Only Printed Strings"
      label: "Show/Hide Foot Note"
      sql: {% if Aging_Aggregation_Type._parameter_value == "'Cumulative Aging'"%}
                                    "Show"
                        {% else %}
                                    "Hide"
                        {%  endif %} ;;
    }

    dimension: Combined_Seperated_Show_Hide{
      type: string
      group_label: "Only Printed Strings"
      label: "Combined/Separated Show Hide"
      sql: {% if View_Type._parameter_value == "'Resolved'" %}
                              "Combined"
                        {% else %}
                              "Separated"
                        {% endif %} ;;
    }

    dimension: Investigator_Resolver_text {
      type: string
      group_label: "Only Printed Strings"
      label: "Investigator/Resolver - Text"
      sql: {% if RCA_VS_Remediation._parameter_value == "'RCA'"%}
                                    "Investigator Domain"
                        {% else %}
                                    "Resolver Domain"
                        {%  endif %} ;;
    }

    dimension: Open_VS_Deferred_View {
      type: string
      group_label: "Only Printed Strings"
      label: "Open VS Deferred View"
      sql: {% if Open_Deferred_Swap._parameter_value == "'Deferred Issues'"%}
                                    "Deferred Issues"
                        {% else %}
                                    "Open Issues w/o Deferred Issues"
                        {%  endif %} ;;
    }

    ######################################################################################################################

    dimension: Today {
      type: date
      group_label: "Dates"
      sql: current_date() ;;
    }

    dimension: Investigator_Resolver {
      type: string
      label: "Investigator/Resolver"
      sql: {% if RCA_VS_Remediation._parameter_value == "'RCA'"%}
                      ${issue_investigator}
          {% else %}
                      ${resolver}
          {%  endif %} ;;
    }

    dimension: LOB_Cons_Prod_View {
      type: string
      sql: case when trim(${Consumer_Producer_Domain}) in ('AML Client Risk Rating (sub-domain)','AML Customer Risk Rating (sub-domain)'
                                                          ,'AML Name Screening (sub-domain)','AML Regulatory Reporting (sub-domain)'
                                                          ,'AML Transaction Monitoring (sub-domain)','Anti-Money Laundering','Non-Retail Credit Risk'
                                                          ,'Compliance','Counterparty Credit Risk','Capital Reporting','Liquidity Risk'
                                                          ,'Market Risk','Operational Risk','Retail Credit Risk','Structured Interest Rate Risk'
                                                          ,'Financial Accounting and Reporting - Regulatory Reporting','Human Resources')
                                      then "Corporate Functions"
              when trim(${Consumer_Producer_Domain}) in ('Canadian Banking AML','CB Credit Cards','Commercial Lending','Canadian Private Banking','Customer')
                                      then "Canadian Banking"
              when trim(${Consumer_Producer_Domain}) in ('Canadian Wealth','iTRADE') then "Global Wealth Management"
              when trim(${Consumer_Producer_Domain}) in ('Bahamas and Turks & Caicos Finance Regulatory Reporting','Barbados Finance Regualtory Reporting'
                                                          ,'Cayman Islands Finance Regulatory Reporting','Chile Anti-Money Laundering', 'Colombia Capital Markets'
                                                          ,'Colombia Anti-Money Laundering','COCU','Colombia Customer Individual','COLO'
                                                          ,'Colombia Customer Institution','Colombia Finance Regulatory Reporting'
                                                          ,'Dominican Republic Finance Regulatory Reporting','Mexico Deposit','Mexico Individual Customer'
                                                          ,'Mexico Insitutional Customer','Mexico Lending - Automotive finance'
                                                          ,'Mexico Lending - Credito Familiar ( family credit)'
                                                          ,'Mexico Lending - Prestamos personales (personal loans)','Mexico Lending - Real Estate'
                                                          ,'Mexico Lending - Cards','Panama Finance Regulatory Reporting','Peru Finance Regulatory Reporting'
                                                          ,'Mexico Finance Regulatory Reporting','Jamaica Finance Regulatory Reporting'
                                                          ,'Peru Institutional Customers','Pery Anti-Money Laundering'
                                                          ,'Peru Individual Customers Banca Retail Business Development and Data Analytics')
                                      then "International Banking"
              when trim(${Consumer_Producer_Domain}) in ('US AML','US Credit Risk','US Customer','US Human Resources','US HR','US Legal','US Liquidity'
                                                          ,'US Market Risk','US Trade & Transactions','Global Sanctions Screening'
                                                          ,'GBM Trade Surveillance (Compliance)','US Finance','Finance - GBM - Scotial Capital Inc')
                                      then "Global Banking Markets"
                            else "Others" end;;
    }

    dimension: LOB {
      type: string
      sql: case when trim(${Consumer_Producer_Domain}) in ('AML Client Risk Rating (sub-domain)','AML Customer Risk Rating (sub-domain)'
                                                          ,'AML Name Screening (sub-domain)','AML Regulatory Reporting (sub-domain)'
                                                          ,'AML Transaction Monitoring (sub-domain)','Anti-Money Laundering','Non-Retail Credit Risk'
                                                          ,'Compliance','Counterparty Credit Risk','Capital Reporting','Liquidity Risk'
                                                          ,'Market Risk','Operational Risk','Retail Credit Risk','Structured Interest Rate Risk'
                                                          ,'Financial Accounting and Reporting - Regulatory Reporting','Human Resources')
                                      then "Corporate Functions"
              when trim(${Consumer_Producer_Domain}) in ('Canadian Banking AML','CB Credit Cards','Commercial Lending','Canadian Private Banking','Customer')
                                      then "Canadian Banking"
              when trim(${Consumer_Producer_Domain}) in ('Canadian Wealth','iTRADE') then "Global Wealth Management"
              when trim(${Consumer_Producer_Domain}) in ('Bahamas and Turks & Caicos Finance Regulatory Reporting','Barbados Finance Regualtory Reporting'
                                                          ,'Cayman Islands Finance Regulatory Reporting', 'Colombia Capital Markets','COCU'
                                                          ,'Colombia Customer Individual','Colombia Customer Institution','Colombia Finance Regulatory Reporting'
                                                          ,'Dominican Republic Finance Regulatory Reporting','Mexico Deposit','Mexico Individual Customer'
                                                          ,'Mexico Insitutional Customer','Mexico Lending - Automotive finance'
                                                          ,'Mexico Lending - Credito Familiar ( family credit)'
                                                          ,'Mexico Lending - Prestamos personales (personal loans)','Mexico Lending - Real Estate'
                                                          ,'Mexico Lending - Cards','Panama Finance Regulatory Reporting','Peru Finance Regulatory Reporting'
                                                          ,'Mexico Finance Regulatory Reporting','Jamaica Finance Regulatory Reporting'
                                                          ,'Peru Institutional Customers','Pery Anti-Money Laundering'
                                                          ,'Peru Individual Customers Banca Retail Business Development and Data Analytics')
                                      then "International Banking"
              when trim(${Consumer_Producer_Domain}) in ('US AML','US Credit Risk','US Customer','US Human Resources','US HR','US Legal','US Liquidity'
                                                          ,'US Market Risk','US Trade & Transactions','Global Sanctions Screening'
                                                          ,'GBM Trade Surveillance (Compliance)','US Finance','Finance - GBM - Scotial Capital Inc'
                                                          ,'US Finance Internal Controls (Non-DQ)','US Data Governance Office')
                                      then "Global Banking Markets"
                            else "Others" end;;
    }

    dimension: Past_RCA_REM {
      type: string
      label: "Past RCA/REM"
      group_label: "Dates String"
      sql:  {% if RCA_VS_Remediation._parameter_value == "'RCA'"%}
                      ${past_target_rca_date}
          {% else %}
                      ${past_target_remed_date}
          {%  endif %} ;;
    }

    dimension: RCA_REM_Date_sort {
      type: date
      group_label: "Dates"
      label: "RCA/REM Date sort"
      sql:  {% if RCA_VS_Remediation._parameter_value == "'RCA'"%}
                      ${target_root_cause_analysis_date}
          {% else %}
                      ${target_remd_date}
          {%  endif %} ;;
    }

    dimension: RCA_Pass_Due {
      type: string
      sql: case when ${target_root_cause_analysis_date} < ${etl_process_date_group_date} then "Past Due"
        else FORMAT_DATE("%b-%y", ${target_root_cause_analysis_date}) end ;;
    }

    dimension: REM_Pass_Due {
      type: string
      sql: case when ${target_remd_date} < ${etl_process_date_group_date} then "Past Due"
        else FORMAT_DATE("%b-%y", ${target_remd_date}) end ;;
    }

    dimension: RCA_REM_Field_for_view {
      type: string
      label: "RCA/REM Field for View"
      sql:  {% if RCA_VS_Remediation._parameter_value == "'RCA'"%}
                      ${RCA_Pass_Due}
          {% else %}
                      ${REM_Pass_Due}
          {%  endif %} ;;
    }

    dimension: Severity_group {
      type: string
      label: "Severity (group)"
      sql: case when ${severity} in ('High','Critical') then "Critical & High"
        else 'Other Severity' end;;
    }

    dimension: Severity_Critical_and_High {
      type: string
      sql: case when ${severity} = "High" or ${severity} = "Critical" then "Critical & High"
        else "Non Critical and High" end;;
    }

    dimension: Severity_Critical_and_High_2 {
      type: string
      label: "Severity Critical and High (2)"
      sql: case when ${severity} = "High" or ${severity} = "Critical" then "Critical and High"
        else "Low and Medium" end;;
    }

    dimension: Severity_Priority_Field {
      type: string
      label: "Severity/Priority Field"
      sql: {% if Serverity_Priority_Swap._parameter_value == "'Severity'"%}
                      ${severity}
          {% else %}
                      ${priority}
          {%  endif %} ;;
    }

#################### SETS ####################

    dimension: auto_dq_set {
      group_label: "Sets"
      label: "Auto DQ Set"
      type: yesno
      sql: case when ${System_Manual_Issue} in ("Auto DQ") then true else false end ;;
    }

    dimension: closed_cancelled {
      group_label: "Sets"
      label: "Closed & Cancelled"
      type: yesno
      sql: case when ${status} in ("Cancelled","Closed") then true else false end ;;
    }

    dimension: gc_issue_domains {
      group_label: "Sets"
      label: "GC Issue Domains"
      type: yesno
      sql: case when ${issue_reporter_domain_old} in ("Enterprise Data Quality","Puerto Rico Anti Monay Laundering",
        "US Data Governance Office","US Finance Internal Controls (Non-DQ)") then true else false end ;;
    }

    dimension: gc_issue_only {
      group_label: "Sets"
      label: "GC Issue Only"
      type: yesno
      sql: case when ${sourced_from} in ("GC") then true else false end ;;
    }

    dimension: manual_dq_set {
      group_label: "Sets"
      label: "Manual DQ Set"
      type: yesno
      sql: case when ${System_Manual_Issue} in ("Manual DQ") then true else false end ;;
    }

    dimension: open_items {
      group_label: "Sets"
      label: "Open Items"
      type: yesno
      sql: case when ${status} in ("Cancelled","Closed") then true else false end ;;
    }

    dimension: open_items_with_deferred {
      group_label: "Sets"
      label: "Open Items with Deferred"
      type: yesno
      sql: case when ${status} in ("Cancelled","Closed") then true else false end ;;
    }

    dimension: rca_set {
      group_label: "Sets"
      label: "RCA Set"
      type: yesno
      sql: case when ${status} in ("Root Cause Analysis") then true else false end ;;
    }

    dimension: rca_past_due_only {
      group_label: "Sets"
      label: "RCA Pass Due Only"
      type: yesno
      sql: case when ${RCA_Pass_Due} in ("Past Due") then true else false end ;;
    }

    dimension: rem_set {
      group_label: "Sets"
      label: "Rem Set"
      type: yesno
      sql: case when ${status} in ("Remediation") then true else false end ;;
    }

    dimension: rem_past_due_only {
      group_label: "Sets"
      label: "Rem Pass Due Only"
      type: yesno
      sql: case when ${REM_Pass_Due} in ("Past Due") then true else false end ;;
    }

    dimension: rem_rca {
      group_label: "Sets"
      label: "Rem + RCA"
      type: yesno
      sql: case when ${rca_set}=1 or ${rem_set}=1 then true else false end ;;
    }

    dimension: detail_report {
      type: string
      label: "Detail Report"
      sql: "Detail Report" ;;
      link: {
        label: "Navigate to Detail Report using the applied filters"
        url: "https://badalio.ca.looker.com/dashboards/330?
        &Severity={{ _filters['scotia_dq.Severity_Priority_Field'] | url_encode }}
        &Report+Date={{ _filters['scotia_dq.report_date'] | url_encode }}
        &Department%2FTenant={{ _filters['scotia_dq.department_tenant'] | url_encode }}"
      }
    }

#############################################

    dimension: RCA_REM {
      type: yesno
      label: "RCA/REM"
      # description: "true/false"
      sql: {% if RCA_VS_Remediation._parameter_value == "'RCA'" %}
                  ${rca_set}
              {% else %}
                  ${rem_set}
              {% endif %};;
    }

    dimension: RCA_REM_Pass_Due_Only {
      type: yesno
      label: "RCA/REM Pass Due Only"
      # description: "true/false"
      sql: {% if RCA_VS_Remediation._parameter_value == "'RCA'" %}
                  ${rca_past_due_only}
              {% else %}
                  ${rem_past_due_only}
              {% endif %};;
    }

################################################ MEASURES ##################################################################

    ###################################### DIMENSIONS REFERENCED IN MEASURES ###########

    dimension: Deferred_Aging_dimension {
      type: number
      hidden: yes
      sql: TIMESTAMP_DIFF(${etl_process_date_group_date}, ${deferred_start_date}+1, DAY) ;;
    }

    dimension: Draft_Aging_dimension {
      type: number
      hidden: yes
      sql: TIMESTAMP_DIFF(${etl_process_date_group_date}, ${dq_create_date}+1, DAY) ;;
    }

    dimension: New_Aging_dimension {
      type: number
      hidden: yes
      sql: TIMESTAMP_DIFF(${etl_process_date_group_date}, ${new_start_date}+1, DAY) ;;
    }

    dimension: RCA_Aging_dimension {
      type: number
      hidden: yes
      sql: TIMESTAMP_DIFF(${etl_process_date_group_date}, ${rca_start_date}+1, DAY) ;;
    }

    dimension: REM_Aging_dimension {
      type: number
      hidden: yes
      sql: TIMESTAMP_DIFF(${etl_process_date_group_date}, ${actual_rca_date}+1, DAY) ;;
    }

    dimension: Verification_Aging_dimension {
      type: number
      hidden: yes
      sql: TIMESTAMP_DIFF(${etl_process_date_group_date}, ${actual_remd_date}+1, DAY) ;;
    }

    dimension: Num_Days_Due_RCA_dimension {
      type: number
      hidden: yes
      sql: date_diff(${target_root_cause_analysis_date},current_date(), day) ;;
    }

    dimension: Num_Days_Due_REM_dimension {
      type: number
      hidden: yes
      sql: date_diff(${target_remd_date},current_date(), day) ;;
    }

    dimension: Num_Days_Overdue_dimension {
      type: number
      hidden: yes
      sql: {% if RCA_VS_Remediation._parameter_value == "'RCA'"%}
                                                                 ${Num_Days_Due_RCA_dimension}
                                                        {% else %}
                                                                 ${Num_Days_Due_REM_dimension}
                                                        {%  endif %} ;;
    }

    dimension: Num_Days_Due_Deferred_dimension {
      type: number
      hidden: yes
      sql: date_diff(${target_deferred_date},current_date(), day) ;;
    }

    dimension: Num_Days_Overdue_Deferred_dimension {
      type: number
      hidden: yes
      sql: case when ${Num_Days_Due_Deferred_dimension} >= 0 then ${Num_Days_Due_Deferred_dimension}
        else 0 end;;
    }

    dimension: Aging_dimension {
      type: number
      hidden: yes
      sql: case when ${status} = "Draft" then ${Draft_Aging_dimension}
                                                when ${status} = "New" then ${New_Aging_dimension}
                                                when ${status} = "Root Cause Analysis" then ${RCA_Aging_dimension}
                                                when ${status} = "Remediation" then ${REM_Aging_dimension}
                                                when ${status} = "Verification" then ${Verification_Aging_dimension}
                                                end ;;
                                      # sql: case when ${status} = "DownloadEvent" then ${Draft_Aging_dimension}
                                      #           when ${status} = "MemberEvent" then ${New_Aging_dimension}
                                      #           when ${status} = "PublicEvent" then ${RCA_Aging_dimension}
                                      #           when ${status} = "ForkApplyEvent" then ${REM_Aging_dimension}
                                      #           when ${status} = "CreateEvent" then ${Verification_Aging_dimension}
                                      #           else null
                                      #           end ;;
      }

      dimension: Aging_Cumulative_dimension {
        type: number
        hidden: yes
        sql: case when ${status} = "Draft" then ${Draft_Aging_dimension}
                                                when ${status} in ('New','Root Cause Analysis','Remediation','Verification') then ${New_Aging_dimension}
                                                end ;;
                                      # sql: case when ${status} = "DownloadEvent" then ${Draft_Aging_dimension}
                                      #           when ${status} = "MemberEvent" then ${New_Aging_dimension}
                                      #           when ${status} = "PublicEvent" then ${New_Aging_dimension}
                                      #           when ${status} = "ForkApplyEvent" then ${New_Aging_dimension}
                                      #           when ${status} = "CreateEvent" then ${New_Aging_dimension}
                                      #           else null
                                      #           end ;;
        }

        dimension: number_of_record_dimension {
          type: number
          hidden: yes
          sql: 1 ;;
        }

        dimension: Previous_Period_Percent_dimension {
          type: number
          hidden: yes
          sql: 1 ;;
        }


        ##############################################################################

        measure: Number_of_Record {
          type: sum
          sql: coalesce(${number_of_record_dimension},0) ;;
          drill_fields: [investigator_domain,issue_champion,issue_investigator,issue_reporter,issue_type]
        }

        measure: Deferred_Aging {
          type: sum
          # description: "Aggregates on ETL Process Date & Deferred Start Date, must pull those fields in"
          sql: ${Deferred_Aging_dimension} ;;
        }

        measure: Avg_Deferred_Aging {
          type: average
          # description: "Aggregates on ETL Process Date & Deferred Start Date, must pull those fields in"
          sql: ${Deferred_Aging_dimension} ;;
        }

        measure: Draft_Aging {
          type: sum
          # description: "Aggregates on ETL Process Date & DQ Create Date, must pull those fields in"
          sql: ${Draft_Aging_dimension} ;;
        }

        measure: New_Aging {
          type: sum
          # description: "Aggregates on ETL Process Date & New Start Date, must pull those fields in"
          sql: ${New_Aging_dimension} ;;
        }

        measure: RCA_Aging {
          type: sum
          # description: "Aggregates on ETL Process Date & RCA Start Date, must pull those fields in"
          sql: ${RCA_Aging_dimension} ;;
        }

        measure: REM_Aging {
          type: sum
          # description: "Aggregates on ETL Process Date & Actual RCA Date, must pull those fields in"
          sql: ${REM_Aging_dimension} ;;
        }

        measure: Verification_Aging {
          type: sum
          # description: "Aggregates on ETL Process Date & Actual Remd Date, must pull those fields in"
          sql: ${Verification_Aging_dimension} ;;
        }

        measure: Aging {
          type: sum
          # description: "Aggregates on ETL Process Date, DQ Create Date, New Start Date, RCA Start Date, Actual RCA Date and Actual Remd Date. Must pull those fields in"
          sql: ${Aging_dimension} ;;
        }

        measure: Avg_Aging {
          type: average
          sql: ${Aging_dimension} ;;
        }

        measure: Aging_Cumulative {
          type: sum
          # description: "Aggregates on ETL Process Date, DQ Create Date and New Start Date. Must pull those fields in"
          sql: ${Aging_Cumulative_dimension} ;;
        }

        measure: Avg_Aging_Cumulative {
          type: average
          sql: ${Aging_Cumulative_dimension} ;;
        }

        measure: Avg_Aging_Tooltip {
          type: number
          sql:{% if Aging_Aggregation_Type._parameter_value == "'Cumulative Aging'" %}
                            ${Avg_Aging}
                      {% else %}
                            ${Avg_Aging_Cumulative}
                      {% endif %};;

        }

        measure: Num_Days_Due_RCA {
          type: sum
          # description: "Aggregates on Target Root Cause Analysis Date, must pull this field in"
          sql: ${Num_Days_Due_RCA_dimension} ;;
        }

        measure: Num_Days_Due_REM {
          type: sum
          # description: "Aggregates on Target Remd Date, must pull this field in"
          sql: ${Num_Days_Due_REM_dimension} ;;
        }

        measure: Num_Days_Overdue {
          type: sum
          label: "# Days Overdue"
          # description: "Aggregates on Target Root Cause Analysis Date and Target Remd Date, must pull these fields in"
          sql: ${Num_Days_Overdue_dimension} ;;
        }

        measure: Num_Days_Due_Deferred {
          type: sum
          # description: "Aggregates on Target Deferred Date, must pull this field in"
          sql: ${Num_Days_Due_Deferred_dimension};;
        }

        measure: Num_Days_Overdue_Deferred {
          type: sum
          label: "# Days Overdue Deferred"
          # description: "Aggregates on Target Deferred Date, must pull this field in"
          sql: ${Num_Days_Overdue_Deferred_dimension};;
        }

        measure: Num_Days_Overdue_Deferred_Tooltip {
          type: sum
          label: "# Days Overdue Deferred Tooltip"
          # description: "Aggregates on Target Deferred Date and ETL Process Date must pull these fields in"
          sql: case when ${Deferred_Past_Due} = "Past Due" then ${Num_Days_Overdue_Deferred_dimension}
            else null end;;
        }

        measure: Num_Days_Overdue_Tooltip {
          type: sum
          label: "# Days Overdue Tooltip"
          # description: "Aggregates on Target Root Cause Analysis Date and ETL Process Date must pull these fields in"
          sql: case when ${RCA_REM_Field_for_view} = "Past Due" then ${Num_Days_Overdue_dimension} else null end ;;
        }

        measure: Cancelled_Issues {
          type: sum
          sql: case when ${status} = 'Cancelled' then 1 else 0 end ;;
          # sql: case when ${status} in ('PushEvent','PullRequestEvent','IssueCommentEvent') then 1 else 0 end ;;
        }

        measure: Closed_Issues {
          type: sum
          sql: case when ${status} = 'Closed' then 1 else 0 end ;;
          # sql: case when ${status} in ('CreateEvent','CommitCommentEvent','ForkEvent') then 1 else 0 end ;;
        }

        measure: Count_of_Critical_High_Severity {
          type: sum
          label: "Count of Critical & High - Severity"
          sql: case when ${Severity_group} = "Critical & High" then ${number_of_record_dimension} else null end ;;
        }

        measure: Previous_Period {
          type: number
          sql: 1 ;;
        }

        measure: Previous_Period_Percent {
          type: number
          label: "Previous Period %"
          sql: ${Previous_Period_Percent_dimension} ;;
        }

        measure: Decrease_from_Previous_Period {
          type: number
          sql: case when ${Previous_Period_Percent_dimension} < 0 then ${Previous_Period_Percent_dimension} end ;;
        }

        measure: Increase_from_Previous_Period {
          type: number
          sql: case when ${Previous_Period_Percent_dimension} > 0 then ${Previous_Period_Percent_dimension} end ;;
        }

        measure: Same_from_Previous_Period {
          type: number
          sql: case when ${Previous_Period_Percent_dimension} = 0 then ${Previous_Period_Percent_dimension} end ;;
        }

        measure: Auto_DQ {
          type: sum
          sql: case when ${System_Manual_Issue} = 'Auto DQ' then 1 end ;;
        }

        measure: Manual_DQ{
          type: sum
          sql: case when ${System_Manual_Issue} = 'Manual DQ' then 1 end ;;
        }

        measure: number_of_times_reforecasted_Deferred {
          type: number
          sql: round(avg(char_length(${past_target_deferred_date})),2) ;;
        }

        measure: number_of_times_reforecasted_RCA {
          type: number
          sql: round(avg(char_length(${past_target_rca_date})),2) ;;
        }

        measure: number_of_times_reforecasted_REM {
          type: number
          sql: round(avg(char_length(${past_target_remed_date})),2) ;;
        }

        measure: Open_Issues {
          type: sum
          sql: case when ${status} in ('Closed','Cancelled') then 0 else 1 end ;;
        }

        measure: RCA_REM_Reforecasting_Count {
          type: number
          label: "RCA/REM Reforecasting Count"
          sql:{% if RCA_VS_Remediation._parameter_value == "'RCA'" %}
                               ${number_of_times_reforecasted_RCA}
                        {% else %}
                               ${number_of_times_reforecasted_REM}
                        {% endif %};;
        }

        measure: Resolved_Issues {
          type: number
          sql: ${Cancelled_Issues} + ${Closed_Issues} ;;
        }

        measure: Sort_for_Closed_Cancelled_Orders {
          type: number
          label: "Sort for Closed/Cancelled Orders"
          sql:{% if View_Type._parameter_value == "'Resolved'" %}
                  ${Resolved_Issues}
            {% else %}
                  {% if Cancelled_vs_closed_sort._parameter_value == "'2'" %}
                          ${Cancelled_Issues}
                      {% else %}
                          ${Closed_Issues}
                      {% endif %}
            {% endif %};;
        }

        measure: Title_Combined_Separated_Total {
          type: string
          sql: {% if View_Type._parameter_value == "'Resolved'" %}
                               concat(cast(${Resolved_Issues} as string),' ','Resolved Issues')
                        {% else %}
                               concat(cast(${Closed_Issues} as string),' ','Closed &',' ',cast(${Cancelled_Issues} as string),' Cancelled Issues')
                        {% endif %}
  ;;
        }


      }
