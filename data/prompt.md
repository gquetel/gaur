# Premier prompt: contexte

```
This is the parse tree of two SQL queries. We would like to characterise the semantic of each query using the grammar rules used during parsing.  
 
UPDATE regions SET keywords = "Airports in Gorišnica" WHERE iso_country = "KG";
digraph query {
    "start_entry" -> "sql_statement";
    "sql_statement" -> "END_OF_INPUT";
    "sql_statement" -> "simple_statement_or_begin";
    "simple_statement_or_begin" -> "simple_statement";
    "simple_statement" -> "update_stmt";
    "update_stmt" -> "opt_simple_limit";
    "update_stmt" -> "opt_order_clause";
    "update_stmt" -> "opt_where_clause";
    "update_stmt" -> "update_list";
    "update_stmt" -> "SET_SYM";
    "update_stmt" -> "table_reference_list";
    "update_stmt" -> "opt_ignore";
    "update_stmt" -> "opt_low_priority";
    "update_stmt" -> "UPDATE_SYM";
    "update_stmt" -> "opt_with_clause";
    "opt_where_clause" -> "where_clause";
    "where_clause" -> "expr";
    "where_clause" -> "WHERE";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "bool_pri" -> "comp_op";
    "bool_pri" -> "bool_pri";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "literal_or_null";
    "literal_or_null" -> "literal";
    "literal" -> "text_literal";
    "text_literal" -> "TEXT_STRING";
    "comp_op" -> "EQ";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "simple_ident";
    "simple_ident" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "update_list" -> "update_elem";
    "update_elem" -> "expr_or_default";
    "update_elem" -> "equal";
    "update_elem" -> "simple_ident_nospvar";
    "expr_or_default" -> "expr";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "literal_or_null";
    "literal_or_null" -> "literal";
    "literal" -> "text_literal";
    "text_literal" -> "TEXT_STRING";
    "equal" -> "EQ";
    "simple_ident_nospvar" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "table_reference_list" -> "table_reference";
    "table_reference" -> "table_factor";
    "table_factor" -> "single_table";
    "single_table" -> "opt_tablesample_clause";
    "single_table" -> "opt_key_definition";
    "single_table" -> "opt_table_alias";
    "single_table" -> "opt_use_partition";
    "single_table" -> "table_ident";
    "opt_key_definition" -> "opt_index_hints_list";
    "table_ident" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
}

SELECT a.name, a.municipality, a.iso_country FROM airport a WHERE a.type IN ('large_airport', 'medium_airport') AND a.iso_country = "US"
digraph query {
    "start_entry" -> "sql_statement";
    "sql_statement" -> "END_OF_INPUT";
    "sql_statement" -> "simple_statement_or_begin";
    "simple_statement_or_begin" -> "simple_statement";
    "simple_statement" -> "select_stmt";
    "select_stmt" -> "query_expression";
    "query_expression" -> "opt_limit_clause";
    "query_expression" -> "opt_order_clause";
    "query_expression" -> "query_expression_body";
    "query_expression_body" -> "query_primary";
    "query_primary" -> "query_specification";
    "query_specification" -> "opt_qualify_clause";
    "query_specification" -> "opt_window_clause";
    "query_specification" -> "opt_having_clause";
    "query_specification" -> "opt_group_clause";
    "query_specification" -> "opt_where_clause";
    "query_specification" -> "opt_from_clause";
    "query_specification" -> "select_item_list";
    "query_specification" -> "select_options";
    "query_specification" -> "SELECT_SYM";
    "opt_where_clause" -> "where_clause";
    "where_clause" -> "expr";
    "where_clause" -> "WHERE";
    "expr" -> "expr";
    "expr" -> "and";
    "expr" -> "expr";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "bool_pri" -> "comp_op";
    "bool_pri" -> "bool_pri";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "literal_or_null";
    "literal_or_null" -> "literal";
    "literal" -> "text_literal";
    "text_literal" -> "TEXT_STRING";
    "comp_op" -> "EQ";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "simple_ident";
    "simple_ident" -> "simple_ident_q";
    "simple_ident_q" -> "ident";
    "simple_ident_q" -> "827_";
    "simple_ident_q" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "and" -> "AND_SYM";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "822_";
    "predicate" -> "expr_list";
    "predicate" -> "826_";
    "predicate" -> "expr";
    "predicate" -> "821_";
    "predicate" -> "IN_SYM";
    "predicate" -> "bit_expr";
    "expr_list" -> "expr";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "literal_or_null";
    "literal_or_null" -> "literal";
    "literal" -> "text_literal";
    "text_literal" -> "TEXT_STRING";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "literal_or_null";
    "literal_or_null" -> "literal";
    "literal" -> "text_literal";
    "text_literal" -> "TEXT_STRING";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "simple_ident";
    "simple_ident" -> "simple_ident_q";
    "simple_ident_q" -> "ident";
    "simple_ident_q" -> "827_";
    "simple_ident_q" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "opt_from_clause" -> "from_clause";
    "from_clause" -> "from_tables";
    "from_clause" -> "FROM";
    "from_tables" -> "table_reference_list";
    "table_reference_list" -> "table_reference";
    "table_reference" -> "table_factor";
    "table_factor" -> "single_table";
    "single_table" -> "opt_tablesample_clause";
    "single_table" -> "opt_key_definition";
    "single_table" -> "opt_table_alias";
    "single_table" -> "opt_use_partition";
    "single_table" -> "table_ident";
    "opt_key_definition" -> "opt_index_hints_list";
    "opt_table_alias" -> "ident";
    "opt_table_alias" -> "opt_as";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "table_ident" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "select_item_list" -> "select_item";
    "select_item_list" -> "826_";
    "select_item_list" -> "select_item_list";
    "select_item" -> "select_alias";
    "select_item" -> "expr";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "simple_ident";
    "simple_ident" -> "simple_ident_q";
    "simple_ident_q" -> "ident";
    "simple_ident_q" -> "827_";
    "simple_ident_q" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "select_item_list" -> "select_item";
    "select_item_list" -> "826_";
    "select_item_list" -> "select_item_list";
    "select_item" -> "select_alias";
    "select_item" -> "expr";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "simple_ident";
    "simple_ident" -> "simple_ident_q";
    "simple_ident_q" -> "ident";
    "simple_ident_q" -> "827_";
    "simple_ident_q" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "select_item_list" -> "select_item";
    "select_item" -> "select_alias";
    "select_item" -> "expr";
    "expr" -> "bool_pri";
    "bool_pri" -> "predicate";
    "predicate" -> "bit_expr";
    "bit_expr" -> "simple_expr";
    "simple_expr" -> "simple_ident";
    "simple_ident" -> "simple_ident_q";
    "simple_ident_q" -> "ident";
    "simple_ident_q" -> "827_";
    "simple_ident_q" -> "ident";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
    "ident" -> "IDENT_sys";
    "IDENT_sys" -> "IDENT_QUOTED";
}

Wait for my further instructions. 
```

# Second prompt: liste des règles de la grammaire

```
Ultimately we will associate a tags to each MySQL grammar rule that are as follows:  

start_entry sql_statement 835_1 opt_end_of_input simple_statement_or_begin simple_statement deallocate deallocate_or_drop prepare prepare_src execute 844_2 execute_using execute_var_list execute_var_ident help 849_3 change_replication_stmt 851_4 852_5 filter_defs filter_def opt_filter_db_list filter_db_list filter_db_ident opt_filter_db_pair_list filter_db_pair_list opt_filter_table_list filter_table_list filter_table_ident opt_filter_string_list filter_string_list filter_string source_defs source_def ignore_server_id_list ignore_server_id privilege_check_def table_primary_key_check_def assign_gtids_to_anonymous_transactions_def source_tls_ciphersuites_def source_file_def opt_channel create_table_stmt create_role_stmt create_resource_group_stmt create 880_6 create_srs_stmt srs_attributes default_role_clause create_index_stmt server_options_list server_option event_tail 888_7 ev_schedule_time 890_8 opt_ev_status ev_starts ev_ends opt_ev_on_completion ev_on_completion opt_ev_comment ev_sql_stmt 898_9 ev_sql_stmt_inner sp_name sp_a_chistics sp_c_chistics sp_chistic sp_c_chistic sp_suid call_stmt opt_paren_expr_list sp_fdparam_list sp_fdparams sp_fdparam sp_pdparam_list sp_pdparams sp_pdparam sp_opt_inout sp_proc_stmts sp_proc_stmts1 sp_decls sp_decl 919_10 920_11 sp_handler_type sp_hcond_list sp_hcond_element sp_cond sqlstate opt_value sp_hcond signal_stmt signal_value opt_signal_value opt_set_signal_information signal_information_item_list signal_allowed_expr signal_condition_information_item_name resignal_stmt get_diagnostics which_area diagnostics_information statement_information statement_information_item simple_target_specification statement_information_item_name condition_number condition_information condition_information_item condition_information_item_name sp_decl_idents sp_opt_default sp_proc_stmt sp_proc_stmt_if 951_12 sp_proc_stmt_statement 953_13 sp_proc_stmt_return 955_14 sp_proc_stmt_unlabeled 957_15 sp_proc_stmt_leave sp_proc_stmt_iterate sp_proc_stmt_open sp_proc_stmt_fetch 962_16 sp_proc_stmt_close sp_opt_fetch_noise sp_fetch_list sp_if 967_17 968_18 969_19 sp_elseifs case_stmt_specification simple_case_stmt 973_20 974_21 searched_case_stmt 976_22 simple_when_clause_list searched_when_clause_list simple_when_clause 980_23 981_24 searched_when_clause 983_25 984_26 else_clause_opt sp_labeled_control 987_27 sp_opt_label sp_labeled_block 990_28 sp_unlabeled_block 992_29 sp_block_content 994_30 sp_unlabeled_control 996_31 997_32 998_33 999_34 trg_action_time trg_event opt_ts_datafile_name opt_logfile_group_name opt_tablespace_options tablespace_option_list tablespace_option opt_alter_tablespace_options alter_tablespace_option_list alter_tablespace_option opt_undo_tablespace_options undo_tablespace_option_list undo_tablespace_option opt_logfile_group_options logfile_group_option_list logfile_group_option opt_alter_logfile_group_options alter_logfile_group_option_list alter_logfile_group_option ts_datafile undo_tablespace_state lg_undofile ts_option_initial_size ts_option_autoextend_size option_autoextend_size ts_option_max_size ts_option_extent_size ts_option_undo_buffer_size ts_option_redo_buffer_size ts_option_nodegroup ts_option_comment ts_option_engine ts_option_file_block_size ts_option_wait ts_option_encryption ts_option_engine_attribute size_number opt_create_table_options_etc opt_create_partitioning_etc opt_duplicate_as_qe as_create_query_expression partition_clause part_type_def opt_linear opt_key_algo opt_num_parts opt_sub_part opt_name_list name_list opt_num_subparts opt_part_defs part_def_list part_definition opt_part_values part_func_max part_values_in part_value_list part_value_item_list_paren 1058_35 part_value_item_list part_value_item opt_sub_partition sub_part_list sub_part_definition opt_part_options part_option_list part_option alter_database_options alter_database_option opt_create_database_options create_database_options create_database_option opt_if_not_exists create_table_options_space_separated create_table_options opt_comma create_table_option ternary_option default_charset default_collation default_encryption row_types merge_insert_types udf_type table_element_list table_element column_def opt_references table_constraint_def check_constraint opt_constraint_name opt_not opt_constraint_enforcement constraint_enforcement field_def opt_generated_always opt_stored_attribute type spatial_type nchar varchar nvarchar int_type real_type opt_PRECISION numeric_type standard_float_options float_options precision type_datetime_precision func_datetime_precision field_options field_opt_list field_option field_length opt_field_length opt_precision opt_column_attribute_list column_attribute_list column_attribute column_format storage_media now now_or_signed_literal character_set charset_name opt_load_data_charset old_or_new_charset_name old_or_new_charset_name_or_default collation_name opt_collate opt_default ascii unicode opt_charset_with_opt_binary opt_bin_mod ws_num_codepoints 1137_36 opt_primary references opt_ref_list reference_list opt_match_clause opt_on_update_delete delete_option constraint_key_type key_or_index opt_key_or_index keys_or_index opt_unique opt_fulltext_index_options fulltext_index_options fulltext_index_option opt_spatial_index_options spatial_index_options

spatial_index_option opt_index_options index_options index_option common_index_option opt_index_name_and_type opt_index_type_clause index_type_clause visibility index_type key_list key_part key_list_with_expression key_part_with_expression opt_ident string_list alter_table_stmt alter_database_stmt 1173_37 alter_procedure_stmt 1175_38 alter_function_stmt 1177_39 alter_view_stmt 1179_40 1180_41 alter_event_stmt 1182_42 alter_logfile_stmt alter_tablespace_stmt alter_undo_tablespace_stmt alter_server_stmt alter_user_stmt opt_replace_password alter_resource_group_stmt alter_user_command opt_user_attribute opt_account_lock_password_expire_options opt_account_lock_password_expire_option_list opt_account_lock_password_expire_option connect_options connect_option_list connect_option user_func ev_alter_on_schedule_completion opt_ev_rename_to opt_ev_sql_stmt ident_or_empty opt_alter_table_actions standalone_alter_table_action alter_table_partition_options opt_alter_command_list standalone_alter_commands opt_with_validation with_validation all_or_alt_part_name_list alter_list alter_commands_modifier_list alter_list_item alter_commands_modifier opt_index_lock_and_algorithm alter_algorithm_option alter_algorithm_option_value alter_lock_option alter_lock_option_value opt_column opt_ignore opt_restrict opt_place opt_to group_replication group_replication_start opt_group_replication_start_options group_replication_start_options group_replication_start_option group_replication_user group_replication_password group_replication_plugin_auth stop_replica_stmt start_replica_stmt 1235_43 1236_44 start opt_start_transaction_option_list start_transaction_option_list start_transaction_option opt_user_option opt_password_option opt_default_auth_option opt_plugin_dir_option opt_replica_thread_option_list replica_thread_option_list replica_thread_option opt_replica_until replica_until checksum opt_checksum_type repair_table_stmt opt_mi_repair_types mi_repair_types mi_repair_type analyze_table_stmt opt_histogram_auto_update opt_histogram_num_buckets opt_histogram_update_param opt_histogram binlog_base64_event check_table_stmt opt_mi_check_types mi_check_types mi_check_type optimize_table_stmt opt_no_write_to_binlog rename 1269_45 rename_list table_to_table_list table_to_table keycache_stmt keycache_list assign_to_keycache key_cache_name preload_stmt preload_list preload_keys adm_partition opt_cache_key_list opt_ignore_leaves select_stmt select_stmt_with_into query_expression query_expression_body query_expression_parens query_primary query_specification opt_from_clause from_clause from_tables table_reference_list table_value_constructor explicit_table select_options select_option_list select_option locking_clause_list locking_clause lock_strength table_locking_list opt_locked_row_action locked_row_action select_item_list select_item select_alias optional_braces expr bool_pri predicate opt_of bit_expr or and not not2 comp_op all_or_any simple_expr opt_array_cast function_call_keyword function_call_nonkeyword opt_returning_type function_call_conflict geometry_function function_call_generic fulltext_options opt_natural_language_mode opt_query_expansion opt_udf_expr_list udf_expr_list udf_expr set_function_specification sum_expr sampling_method sampling_percentage opt_tablesample_clause window_func_call opt_lead_lag_info stable_integer param_or_var opt_ll_default opt_null_treatment opt_from_first_last opt_windowing_clause windowing_clause window_name_or_spec window_name window_spec window_spec_details opt_existing_window_name opt_partition_clause opt_window_order_by_clause opt_window_frame_clause window_frame_extent window_frame_start window_frame_between window_frame_bound opt_window_frame_exclusion window_frame_units grouping_operation in_expression_user_variable_assignment rvalue_system_or_user_variable opt_distinct opt_gconcat_separator opt_gorder_clause gorder_list in_sum_expr cast_type opt_expr_list expr_list ident_list_arg ident_list opt_expr opt_else when_list table_reference esc_table_reference joined_table natural_join_type inner_join_type outer_join_type opt_inner opt_outer opt_use_partition use_partition table_factor table_reference_list_parens single_table_parens single_table joined_table_parens derived_table table_function columns_clause columns_list jt_column jt_column_type opt_on_empty_or_error opt_on_empty_or_error_json_table on_empty on_error json_on_response index_hint_clause index_hint_type index_hint_definition index_hints_list opt_index_hints_list opt_key_definition opt_key_usage_list key_usage_element key_usage_list using_list ident_string_list interval interval_time_stamp date_time_type opt_as opt_table_alias opt_all opt_where_clause where_clause opt_having_clause opt_qualify_clause with_clause with_list common_table_expr opt_derived_column_list simple_ident_list opt_window_clause window_definition_list window_definition opt_group_clause group_list olap_opt alter_order_list alter_order_item opt_order_clause order_clause order_list opt_ordering_direction ordering_direction opt_limit_clause limit_clause limit_options limit_option opt_simple_limit ulong_num real_ulong_num ulonglong_num real_ulonglong_num dec_num_error dec_num select_var_list select_var_ident into_clause into_destination do_stmt drop_table_stmt 

drop_index_stmt drop_database_stmt drop_function_stmt drop_resource_group_stmt drop_procedure_stmt drop_user_stmt drop_view_stmt drop_event_stmt drop_trigger_stmt drop_tablespace_stmt drop_undo_tablespace_stmt drop_logfile_stmt drop_server_stmt drop_srs_stmt drop_role_stmt table_list table_alias_ref_list if_exists opt_ignore_unknown_user opt_temporary opt_drop_ts_options drop_ts_option_list drop_ts_option insert_stmt replace_stmt insert_lock_option replace_lock_option opt_INTO insert_from_constructor insert_query_expression insert_columns insert_values query_expression_with_opt_locking_clauses value_or_values values_list values_row_list equal opt_equal row_value row_value_explicit opt_values values expr_or_default opt_values_reference opt_insert_update_list update_stmt opt_with_clause update_list update_elem opt_low_priority delete_stmt opt_wild opt_delete_options opt_delete_option truncate_stmt opt_table opt_profile_defs profile_defs profile_def opt_for_query show_databases_stmt show_tables_stmt show_triggers_stmt show_events_stmt show_table_status_stmt show_open_tables_stmt show_plugins_stmt show_engine_logs_stmt show_engine_mutex_stmt show_engine_status_stmt show_columns_stmt show_binary_logs_stmt show_replicas_stmt show_binlog_events_stmt show_relaylog_events_stmt show_keys_stmt show_engines_stmt show_count_warnings_stmt show_count_errors_stmt show_warnings_stmt show_errors_stmt show_profiles_stmt show_profile_stmt show_status_stmt show_processlist_stmt show_variables_stmt show_character_set_stmt show_collation_stmt show_privileges_stmt show_grants_stmt show_create_database_stmt show_create_table_stmt show_create_view_stmt show_binary_log_status_stmt show_replica_status_stmt show_create_procedure_stmt show_create_function_stmt show_create_trigger_stmt show_procedure_status_stmt show_function_status_stmt show_procedure_code_stmt show_function_code_stmt show_create_event_stmt show_create_user_stmt show_parse_tree_stmt engine_or_all opt_storage opt_db opt_full opt_extended opt_show_cmd_type from_or_in opt_binlog_in binlog_from opt_wild_or_where describe_stmt explain_stmt explainable_stmt describe_command opt_explain_format opt_explain_options opt_explain_into opt_explain_for_schema opt_describe_column flush 1585_46 flush_options 1587_47 opt_flush_lock 1589_48 flush_options_list flush_option opt_table_list reset 1594_49 reset_options opt_if_exists_ident persisted_variable_ident reset_option 1599_50 1600_51 opt_replica_reset_options source_reset_options purge 1604_52 purge_options purge_option kill kill_option use load_stmt data_or_xml opt_local opt_from_keyword load_data_lock load_source_type opt_source_count opt_source_order opt_duplicate duplicate opt_field_term field_term_list field_term opt_line_term line_term_list line_term opt_xml_rows_identified_by opt_ignore_lines lines_or_rows opt_field_or_var_spec fields_or_vars field_or_var opt_load_data_set_spec load_data_set_list load_data_set_elem opt_load_algorithm opt_compression_algorithm opt_load_parallel opt_load_memory text_literal text_string param_marker signed_literal signed_literal_or_null null_as_literal literal literal_or_null NUM_literal int64_literal temporal_literal opt_interval insert_column table_wild order_expr grouping_expr simple_ident simple_ident_nospvar simple_ident_q table_ident table_ident_opt_wild IDENT_sys TEXT_STRING_sys_nonewline filter_wild_db_table_string TEXT_STRING_sys TEXT_STRING_literal TEXT_STRING_filesystem TEXT_STRING_password TEXT_STRING_hash TEXT_STRING_validated ident role_ident label_ident lvalue_ident ident_or_text role_ident_or_text user_ident_or_text user role schema ident_keyword ident_keywords_ambiguous_1_roles_and_labels ident_keywords_ambiguous_2_labels label_keyword ident_keywords_ambiguous_3_roles ident_keywords_unambiguous role_keyword lvalue_keyword ident_keywords_ambiguous_4_system_variables set start_option_value_list set_role_stmt opt_except_role_list set_resource_group_stmt thread_id_list thread_id_list_options start_option_value_list_following_option_type option_value_list_continued option_value_list option_value option_type opt_var_type opt_rvalue_system_variable_type opt_set_var_ident_type option_value_following_option_type option_value_no_option_type lvalue_variable rvalue_system_variable transaction_characteristics transaction_access_mode opt_transaction_access_mode isolation_level opt_isolation_level transaction_access_mode_types isolation_types set_expr_or_default lock 1716_53 table_or_tables table_lock_list table_lock lock_option unlock 1722_54 shutdown_stmt restart_server_stmt alter_instance_stmt alter_instance_action handler_stmt handler_scan_function handler_rkey_function handler_rkey_mode revoke 1732_55 grant 1734_56 opt_acl_type opt_privileges role_or_privilege_list role_or_privilege opt_with_admin_option opt_and require_list require_list_element grant_ident user_list role_list opt_retain_current_password opt_discard_old_password opt_user_registration create_user opt_create_user_with_mfa identification identified_by_password identified_by_random_password identified_with_plugin identified_with_plugin_as_auth identified_with_plugin_by_password identified_with_plugin_by_random_password opt_initial_auth alter_user factor create_user_list alter_user_list opt_column_list column_list require_clause 

grant_options opt_grant_option opt_with_roles opt_grant_as begin_stmt 1771_57 opt_work opt_chain opt_release opt_savepoint commit rollback savepoint release union_option row_subquery table_subquery subquery query_spec_option init_lex_create_info view_or_trigger_or_sp_or_event definer_tail no_definer_tail definer_opt no_definer definer view_replace_or_algorithm view_replace view_algorithm view_suid view_tail 1797_58 view_query_block view_check_option trigger_action_order trigger_follows_precedes_clause trigger_tail 1803_59 udf_tail sf_tail 1806_60 1807_61 1808_62 1809_63 routine_string stored_routine_body sp_tail 1813_64 1814_65 1815_66 1816_67 xa opt_convert_xid xid begin_or_start opt_join_or_resume opt_one_phase opt_suspend install_option_type install_set_rvalue install_set_value install_set_value_list opt_install_set_value_list install_stmt uninstall TEXT_STRING_sys_list import_stmt clone_stmt opt_datadir_ssl opt_ssl resource_group_types opt_resource_group_vcpu_list vcpu_range_spec_list vcpu_num_or_range signed_num opt_resource_group_priority opt_resource_group_enable_disable opt_force json_attribute

If you had to associate a semantic tag to each of the MySQL grammar rule. Which categories would you create ? (Try to limit yourself to 20).
```


### Prompts d'association de règles

Les LLMs avaient du mal à se souvenir de toutes les règles en détail, donner des plus petit chunks de l'ensemble des règles permettait de réduire le nombre de règles qui disparaissent dans l'output.

```
Given these 20 semantic tags: LISTE

Associate a tag to each of the following MySQL grammar rule. Output the result in a csv format. 

start_entry sql_statement 835_1 opt_end_of_input simple_statement_or_begin simple_statement deallocate deallocate_or_drop prepare prepare_src execute 844_2 execute_using execute_var_list execute_var_ident help 849_3 change_replication_stmt 851_4 852_5 filter_defs filter_def opt_filter_db_list filter_db_list filter_db_ident opt_filter_db_pair_list filter_db_pair_list opt_filter_table_list filter_table_list filter_table_ident opt_filter_string_list filter_string_list filter_string source_defs source_def ignore_server_id_list ignore_server_id privilege_check_def table_primary_key_check_def assign_gtids_to_anonymous_transactions_def source_tls_ciphersuites_def source_file_def opt_channel create_table_stmt create_role_stmt create_resource_group_stmt create 880_6 create_srs_stmt srs_attributes default_role_clause create_index_stmt server_options_list server_option event_tail 888_7 ev_schedule_time 890_8 opt_ev_status ev_starts ev_ends opt_ev_on_completion ev_on_completion opt_ev_comment ev_sql_stmt 898_9 ev_sql_stmt_inner sp_name sp_a_chistics sp_c_chistics sp_chistic sp_c_chistic sp_suid call_stmt opt_paren_expr_list sp_fdparam_list sp_fdparams sp_fdparam sp_pdparam_list sp_pdparams sp_pdparam sp_opt_inout sp_proc_stmts sp_proc_stmts1 sp_decls sp_decl 919_10 920_11 sp_handler_type sp_hcond_list sp_hcond_element sp_cond sqlstate opt_value sp_hcond signal_stmt signal_value opt_signal_value opt_set_signal_information signal_information_item_list signal_allowed_expr signal_condition_information_item_name resignal_stmt get_diagnostics which_area diagnostics_information statement_information statement_information_item simple_target_specification statement_information_item_name condition_number condition_information condition_information_item condition_information_item_name sp_decl_idents sp_opt_default sp_proc_stmt sp_proc_stmt_if 951_12 sp_proc_stmt_statement 953_13 sp_proc_stmt_return 955_14 sp_proc_stmt_unlabeled 957_15 sp_proc_stmt_leave sp_proc_stmt_iterate sp_proc_stmt_open sp_proc_stmt_fetch 962_16 sp_proc_stmt_close sp_opt_fetch_noise sp_fetch_list sp_if 967_17 968_18 969_19 sp_elseifs case_stmt_specification simple_case_stmt 973_20 974_21 searched_case_stmt 976_22 simple_when_clause_list searched_when_clause_list simple_when_clause 980_23 981_24 searched_when_clause 983_25 984_26 else_clause_opt sp_labeled_control 987_27 sp_opt_label sp_labeled_block 990_28 sp_unlabeled_block 992_29 sp_block_content 994_30 sp_unlabeled_control 996_31 997_32 998_33 999_34 trg_action_time trg_event opt_ts_datafile_name opt_logfile_group_name opt_tablespace_options tablespace_option_list tablespace_option opt_alter_tablespace_options alter_tablespace_option_list alter_tablespace_option opt_undo_tablespace_options undo_tablespace_option_list undo_tablespace_option opt_logfile_group_options logfile_group_option_list logfile_group_option opt_alter_logfile_group_options alter_logfile_group_option_list alter_logfile_group_option ts_datafile undo_tablespace_state lg_undofile ts_option_initial_size ts_option_autoextend_size option_autoextend_size ts_option_max_size ts_option_extent_size ts_option_undo_buffer_size ts_option_redo_buffer_size ts_option_nodegroup ts_option_comment ts_option_engine ts_option_file_block_size ts_option_wait ts_option_encryption ts_option_engine_attribute size_number opt_create_table_options_etc opt_create_partitioning_etc opt_duplicate_as_qe as_create_query_expression partition_clause part_type_def opt_linear opt_key_algo opt_num_parts opt_sub_part opt_name_list name_list opt_num_subparts opt_part_defs part_def_list part_definition opt_part_values part_func_max part_values_in part_value_list part_value_item_list_paren 1058_35 part_value_item_list part_value_item opt_sub_partition sub_part_list sub_part_definition opt_part_options part_option_list part_option alter_database_options alter_database_option opt_create_database_options create_database_options create_database_option opt_if_not_exists create_table_options_space_separated create_table_options opt_comma create_table_option ternary_option default_charset default_collation default_encryption row_types merge_insert_types udf_type table_element_list table_element column_def opt_references table_constraint_def check_constraint opt_constraint_name opt_not opt_constraint_enforcement constraint_enforcement field_def opt_generated_always opt_stored_attribute type spatial_type nchar varchar nvarchar int_type real_type opt_PRECISION numeric_type standard_float_options float_options precision type_datetime_precision func_datetime_precision field_options field_opt_list field_option field_length opt_field_length opt_precision opt_column_attribute_list column_attribute_list column_attribute column_format storage_media now now_or_signed_literal character_set charset_name opt_load_data_charset old_or_new_charset_name old_or_new_charset_name_or_default collation_name opt_collate opt_default ascii unicode opt_charset_with_opt_binary opt_bin_mod ws_num_codepoints 1137_36 opt_primary references opt_ref_list reference_list opt_match_clause opt_on_update_delete delete_option constraint_key_type key_or_index opt_key_or_index keys_or_index opt_unique opt_fulltext_index_options fulltext_index_options fulltext_index_option opt_spatial_index_options spatial_index_options
```


```
Given these 20 semantic tags: LISTE 

Associate a tag to each of the following MySQL grammar rule. Output the result in a csv format. 

spatial_index_option opt_index_options index_options index_option common_index_option opt_index_name_and_type opt_index_type_clause index_type_clause visibility index_type key_list key_part key_list_with_expression key_part_with_expression opt_ident string_list alter_table_stmt alter_database_stmt 1173_37 alter_procedure_stmt 1175_38 alter_function_stmt 1177_39 alter_view_stmt 1179_40 1180_41 alter_event_stmt 1182_42 alter_logfile_stmt alter_tablespace_stmt alter_undo_tablespace_stmt alter_server_stmt alter_user_stmt opt_replace_password alter_resource_group_stmt alter_user_command opt_user_attribute opt_account_lock_password_expire_options opt_account_lock_password_expire_option_list opt_account_lock_password_expire_option connect_options connect_option_list connect_option user_func ev_alter_on_schedule_completion opt_ev_rename_to opt_ev_sql_stmt ident_or_empty opt_alter_table_actions standalone_alter_table_action alter_table_partition_options opt_alter_command_list standalone_alter_commands opt_with_validation with_validation all_or_alt_part_name_list alter_list alter_commands_modifier_list alter_list_item alter_commands_modifier opt_index_lock_and_algorithm alter_algorithm_option alter_algorithm_option_value alter_lock_option alter_lock_option_value opt_column opt_ignore opt_restrict opt_place opt_to group_replication group_replication_start opt_group_replication_start_options group_replication_start_options group_replication_start_option group_replication_user group_replication_password group_replication_plugin_auth stop_replica_stmt start_replica_stmt 1235_43 1236_44 start opt_start_transaction_option_list start_transaction_option_list start_transaction_option opt_user_option opt_password_option opt_default_auth_option opt_plugin_dir_option opt_replica_thread_option_list replica_thread_option_list replica_thread_option opt_replica_until replica_until checksum opt_checksum_type repair_table_stmt opt_mi_repair_types mi_repair_types mi_repair_type analyze_table_stmt opt_histogram_auto_update opt_histogram_num_buckets opt_histogram_update_param opt_histogram binlog_base64_event check_table_stmt opt_mi_check_types mi_check_types mi_check_type optimize_table_stmt opt_no_write_to_binlog rename 1269_45 rename_list table_to_table_list table_to_table keycache_stmt keycache_list assign_to_keycache key_cache_name preload_stmt preload_list preload_keys adm_partition opt_cache_key_list opt_ignore_leaves select_stmt select_stmt_with_into query_expression query_expression_body query_expression_parens query_primary query_specification opt_from_clause from_clause from_tables table_reference_list table_value_constructor explicit_table select_options select_option_list select_option locking_clause_list locking_clause lock_strength table_locking_list opt_locked_row_action locked_row_action select_item_list select_item select_alias optional_braces expr bool_pri predicate opt_of bit_expr or and not not2 comp_op all_or_any simple_expr opt_array_cast function_call_keyword function_call_nonkeyword opt_returning_type function_call_conflict geometry_function function_call_generic fulltext_options opt_natural_language_mode opt_query_expansion opt_udf_expr_list udf_expr_list udf_expr set_function_specification sum_expr sampling_method sampling_percentage opt_tablesample_clause window_func_call opt_lead_lag_info stable_integer param_or_var opt_ll_default opt_null_treatment opt_from_first_last opt_windowing_clause windowing_clause window_name_or_spec window_name window_spec window_spec_details opt_existing_window_name opt_partition_clause opt_window_order_by_clause opt_window_frame_clause window_frame_extent window_frame_start window_frame_between window_frame_bound opt_window_frame_exclusion window_frame_units grouping_operation in_expression_user_variable_assignment rvalue_system_or_user_variable opt_distinct opt_gconcat_separator opt_gorder_clause gorder_list in_sum_expr cast_type opt_expr_list expr_list ident_list_arg ident_list opt_expr opt_else when_list table_reference esc_table_reference joined_table natural_join_type inner_join_type outer_join_type opt_inner opt_outer opt_use_partition use_partition table_factor table_reference_list_parens single_table_parens single_table joined_table_parens derived_table table_function columns_clause columns_list jt_column jt_column_type opt_on_empty_or_error opt_on_empty_or_error_json_table on_empty on_error json_on_response index_hint_clause index_hint_type index_hint_definition index_hints_list opt_index_hints_list opt_key_definition opt_key_usage_list key_usage_element key_usage_list using_list ident_string_list interval interval_time_stamp date_time_type opt_as opt_table_alias opt_all opt_where_clause where_clause opt_having_clause opt_qualify_clause with_clause with_list common_table_expr opt_derived_column_list simple_ident_list opt_window_clause window_definition_list window_definition opt_group_clause group_list olap_opt alter_order_list alter_order_item opt_order_clause order_clause order_list opt_ordering_direction ordering_direction opt_limit_clause limit_clause limit_options limit_option opt_simple_limit ulong_num real_ulong_num ulonglong_num real_ulonglong_num dec_num_error dec_num select_var_list select_var_ident into_clause into_destination do_stmt drop_table_stmt 
```

```
Given these 20 semantic tags: LISTE 

Associate a tag to each of the following MySQL grammar rule. Output the result in a csv format. 

drop_index_stmt drop_database_stmt drop_function_stmt drop_resource_group_stmt drop_procedure_stmt drop_user_stmt drop_view_stmt drop_event_stmt drop_trigger_stmt drop_tablespace_stmt drop_undo_tablespace_stmt drop_logfile_stmt drop_server_stmt drop_srs_stmt drop_role_stmt table_list table_alias_ref_list if_exists opt_ignore_unknown_user opt_temporary opt_drop_ts_options drop_ts_option_list drop_ts_option insert_stmt replace_stmt insert_lock_option replace_lock_option opt_INTO insert_from_constructor insert_query_expression insert_columns insert_values query_expression_with_opt_locking_clauses value_or_values values_list values_row_list equal opt_equal row_value row_value_explicit opt_values values expr_or_default opt_values_reference opt_insert_update_list update_stmt opt_with_clause update_list update_elem opt_low_priority delete_stmt opt_wild opt_delete_options opt_delete_option truncate_stmt opt_table opt_profile_defs profile_defs profile_def opt_for_query show_databases_stmt show_tables_stmt show_triggers_stmt show_events_stmt show_table_status_stmt show_open_tables_stmt show_plugins_stmt show_engine_logs_stmt show_engine_mutex_stmt show_engine_status_stmt show_columns_stmt show_binary_logs_stmt show_replicas_stmt show_binlog_events_stmt show_relaylog_events_stmt show_keys_stmt show_engines_stmt show_count_warnings_stmt show_count_errors_stmt show_warnings_stmt show_errors_stmt show_profiles_stmt show_profile_stmt show_status_stmt show_processlist_stmt show_variables_stmt show_character_set_stmt show_collation_stmt show_privileges_stmt show_grants_stmt show_create_database_stmt show_create_table_stmt show_create_view_stmt show_binary_log_status_stmt show_replica_status_stmt show_create_procedure_stmt show_create_function_stmt show_create_trigger_stmt show_procedure_status_stmt show_function_status_stmt show_procedure_code_stmt show_function_code_stmt show_create_event_stmt show_create_user_stmt show_parse_tree_stmt engine_or_all opt_storage opt_db opt_full opt_extended opt_show_cmd_type from_or_in opt_binlog_in binlog_from opt_wild_or_where describe_stmt explain_stmt explainable_stmt describe_command opt_explain_format opt_explain_options opt_explain_into opt_explain_for_schema opt_describe_column flush 1585_46 flush_options 1587_47 opt_flush_lock 1589_48 flush_options_list flush_option opt_table_list reset 1594_49 reset_options opt_if_exists_ident persisted_variable_ident reset_option 1599_50 1600_51 opt_replica_reset_options source_reset_options purge 1604_52 purge_options purge_option kill kill_option use load_stmt data_or_xml opt_local opt_from_keyword load_data_lock load_source_type opt_source_count opt_source_order opt_duplicate duplicate opt_field_term field_term_list field_term opt_line_term line_term_list line_term opt_xml_rows_identified_by opt_ignore_lines lines_or_rows opt_field_or_var_spec fields_or_vars field_or_var opt_load_data_set_spec load_data_set_list load_data_set_elem opt_load_algorithm opt_compression_algorithm opt_load_parallel opt_load_memory text_literal text_string param_marker signed_literal signed_literal_or_null null_as_literal literal literal_or_null NUM_literal int64_literal temporal_literal opt_interval insert_column table_wild order_expr grouping_expr simple_ident simple_ident_nospvar simple_ident_q table_ident table_ident_opt_wild IDENT_sys TEXT_STRING_sys_nonewline filter_wild_db_table_string TEXT_STRING_sys TEXT_STRING_literal TEXT_STRING_filesystem TEXT_STRING_password TEXT_STRING_hash TEXT_STRING_validated ident role_ident label_ident lvalue_ident ident_or_text role_ident_or_text user_ident_or_text user role schema ident_keyword ident_keywords_ambiguous_1_roles_and_labels ident_keywords_ambiguous_2_labels label_keyword ident_keywords_ambiguous_3_roles ident_keywords_unambiguous role_keyword lvalue_keyword ident_keywords_ambiguous_4_system_variables set start_option_value_list set_role_stmt opt_except_role_list set_resource_group_stmt thread_id_list thread_id_list_options start_option_value_list_following_option_type option_value_list_continued option_value_list option_value option_type opt_var_type opt_rvalue_system_variable_type opt_set_var_ident_type option_value_following_option_type option_value_no_option_type lvalue_variable rvalue_system_variable transaction_characteristics transaction_access_mode opt_transaction_access_mode isolation_level opt_isolation_level transaction_access_mode_types isolation_types set_expr_or_default lock 1716_53 table_or_tables table_lock_list table_lock lock_option unlock 1722_54 shutdown_stmt restart_server_stmt alter_instance_stmt alter_instance_action handler_stmt handler_scan_function handler_rkey_function handler_rkey_mode revoke 1732_55 grant 1734_56 opt_acl_type opt_privileges role_or_privilege_list role_or_privilege opt_with_admin_option opt_and require_list require_list_element grant_ident user_list role_list opt_retain_current_password opt_discard_old_password opt_user_registration create_user opt_create_user_with_mfa identification identified_by_password identified_by_random_password identified_with_plugin identified_with_plugin_as_auth identified_with_plugin_by_password identified_with_plugin_by_random_password opt_initial_auth alter_user factor create_user_list alter_user_list opt_column_list column_list require_clause 
```

```
Given these 20 semantic tags: LISTE 

Associate a tag to each of the following MySQL grammar rule. Output the result in a csv format. 

grant_options opt_grant_option opt_with_roles opt_grant_as begin_stmt 1771_57 opt_work opt_chain opt_release opt_savepoint commit rollback savepoint release union_option row_subquery table_subquery subquery query_spec_option init_lex_create_info view_or_trigger_or_sp_or_event definer_tail no_definer_tail definer_opt no_definer definer view_replace_or_algorithm view_replace view_algorithm view_suid view_tail 1797_58 view_query_block view_check_option trigger_action_order trigger_follows_precedes_clause trigger_tail 1803_59 udf_tail sf_tail 1806_60 1807_61 1808_62 1809_63 routine_string stored_routine_body sp_tail 1813_64 1814_65 1815_66 1816_67 xa opt_convert_xid xid begin_or_start opt_join_or_resume opt_one_phase opt_suspend install_option_type install_set_rvalue install_set_value install_set_value_list opt_install_set_value_list install_stmt uninstall TEXT_STRING_sys_list import_stmt clone_stmt opt_datadir_ssl opt_ssl resource_group_types opt_resource_group_vcpu_list vcpu_range_spec_list vcpu_num_or_range signed_num opt_resource_group_priority opt_resource_group_enable_disable opt_force json_attribute
```
