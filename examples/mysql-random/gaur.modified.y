





%{

#define YYP (YYTHD->m_parser_state)
#define YYLIP (& YYTHD->m_parser_state->m_lip)
#define YYPS (& YYTHD->m_parser_state->m_yacc)
#define YYCSCL (YYLIP->query_charset)
#define YYMEM_ROOT (YYTHD->mem_root)
#define YYCLIENT_NO_SCHEMA (YYTHD->get_protocol()->has_client_capability(CLIENT_NO_SCHEMA))

#define YYINITDEPTH 100
#define YYMAXDEPTH 3200                        
#define Lex (YYTHD->lex)
#define Select Lex->current_query_block()

#include <sys/types.h>  

#include <algorithm>
#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cstring>
#include <limits>
#include <memory>
#include <string>
#include <type_traits>
#include <utility>

#include "field_types.h"
#include "ft_global.h"
#include "lex_string.h"
#include "mysql/binlog/event/binlog_event.h"
#include "m_string.h"
#include "my_alloc.h"
#include "my_base.h"
#include "my_check_opt.h"
#include "my_dbug.h"
#include "my_inttypes.h"  
#include "my_sqlcommand.h"
#include "my_sys.h"
#include "my_thread_local.h"
#include "my_time.h"
#include "myisam.h"
#include "myisammrg.h"
#include "mysql/mysql_lex_string.h"
#include "mysql/plugin.h"
#include "mysql/strings/m_ctype.h"
#include "mysql/udf_registration_types.h"
#include "mysql_com.h"
#include "mysql_time.h"
#include "mysqld_error.h"
#include "prealloced_array.h"
#include "sql/auth/auth_acls.h"
#include "sql/auth/auth_common.h"
#include "sql/binlog.h"                          
#include "sql/create_field.h"
#include "sql/dd/types/abstract_table.h"         
#include "sql/dd/types/column.h"
#include "sql/derror.h"
#include "sql/event_parse_data.h"
#include "sql/field.h"
#include "sql/gis/srid.h"                    
#include "sql/handler.h"
#include "sql/item.h"
#include "sql/item_cmpfunc.h"
#include "sql/item_create.h"
#include "sql/item_func.h"
#include "sql/item_geofunc.h"
#include "sql/item_json_func.h"
#include "sql/item_regexp_func.h"
#include "sql/item_row.h"
#include "sql/item_strfunc.h"
#include "sql/item_subselect.h"
#include "sql/item_sum.h"
#include "sql/item_timefunc.h"
#include "sql-common/json_dom.h"
#include "sql-common/json_syntax_check.h"           
#include "sql/key_spec.h"
#include "sql/keycaches.h"
#include "sql/lex_symbol.h"
#include "sql/lex_token.h"
#include "sql/lexer_yystype.h"
#include "sql/mdl.h"
#include "sql/mem_root_array.h"
#include "sql/mysqld.h"
#include "sql/options_mysqld.h"
#include "sql/parse_location.h"
#include "sql/parse_tree_helpers.h"
#include "sql/parse_tree_node_base.h"
#include "sql/parser_yystype.h"
#include "sql/partition_element.h"
#include "sql/partition_info.h"
#include "sql/protocol.h"
#include "sql/query_options.h"
#include "sql/resourcegroups/platform/thread_attrs_api.h"
#include "sql/resourcegroups/resource_group_basic_types.h"
#include "sql/rpl_filter.h"
#include "sql/rpl_replica.h"                       
#include "sql/set_var.h"
#include "sql/sp.h"
#include "sql/sp_head.h"
#include "sql/sp_instr.h"
#include "sql/sp_pcontext.h"
#include "sql/spatial.h"
#include "sql/sql_admin.h"                         
#include "sql/sql_alter.h"                         
#include "sql/sql_backup_lock.h"                   
#include "sql/sql_class.h"      
#include "sql/sql_cmd_srs.h"
#include "sql/sql_component.h"
#include "sql/sql_connect.h"
#include "sql/sql_error.h"
#include "sql/sql_exchange.h"
#include "sql/sql_get_diagnostics.h"               
#include "sql/sql_handler.h"                       
#include "sql/sql_import.h"                        
#include "sql/sql_lex.h"
#include "sql/sql_list.h"
#include "sql/sql_parse.h"                        
#include "sql/sql_plugin.h"                      
#include "sql/sql_profile.h"
#include "sql/sql_select.h"                      
#include "sql/sql_servers.h"
#include "sql/sql_signal.h"
#include "sql/sql_table.h"                        
#include "sql/sql_tablespace.h"                  
#include "sql/sql_trigger.h"                     
#include "sql/sql_udf.h"
#include "sql/system_variables.h"
#include "sql/table.h"
#include "sql/table_function.h"
#include "sql/thr_malloc.h"
#include "sql/trigger_def.h"
#include "sql/window_lex.h"
#include "sql/xa/sql_cmd_xa.h"                   
#include "sql_string.h"
#include "strcont.h"
#include "strings/sql_chars.h"
#include "strxnmov.h"
#include "thr_lock.h"
#include "violite.h"
#include "sql/tablesample.h"


#ifdef _MSC_VER

#pragma warning (disable : 4065)
#endif

using std::min;
using std::max;


static const int MAX_NUMBER_OF_HISTOGRAM_BUCKETS= 1024;




static const int DEFAULT_NUMBER_OF_HISTOGRAM_BUCKETS= 100;

int my_sql_parser_lex(void *yylval, void *yythd);

#define yyoverflow(A,B,C,D,E,F,G,H)           \
  {                                           \
    ulong val= *(H);                          \
    if (my_yyoverflow((B), (D), (F), &val))   \
    {                                         \
      yyerror(nullptr, YYTHD, nullptr, (const char*) (A));\
      return 2;                               \
    }                                         \
    else                                      \
    {                                         \
      *(H)= (YYSIZE_T)val;                    \
    }                                         \
  }

#define MYSQL_YYABORT YYABORT

#define MYSQL_YYABORT_ERROR(...)              \
  do                                          \
  {                                           \
    my_error(__VA_ARGS__);                    \
    MYSQL_YYABORT;                            \
  } while(0)

#define MYSQL_YYABORT_UNLESS(A)         \
  if (!(A))                             \
  {                                     \
    YYTHD->syntax_error();              \
    MYSQL_YYABORT;                      \
  }

#define NEW_PTN new(YYMEM_ROOT)



#define CONTEXTUALIZE(x)                                \
  do                                                    \
  {                                                     \
    std::remove_reference<decltype(*x)>::type::context_t pc(YYTHD, Select); \
    if (YYTHD->is_error() ||                                            \
        (YYTHD->lex->will_contextualize && (x)->contextualize(&pc)))    \
      MYSQL_YYABORT;                                                    \
  } while(0)

#define CONTEXTUALIZE_VIEW(x)                           \
  do                                                    \
  {                                                     \
    std::remove_reference<decltype(*x)>::type::context_t pc(YYTHD, Select); \
    if (YYTHD->is_error() ||                                            \
        (YYTHD->lex->will_contextualize && (x)->contextualize(&pc)))    \
      MYSQL_YYABORT;                                                    \
    if (pc.finalize_query_expression())                                 \
      MYSQL_YYABORT;                                                    \
  } while(0)


#define ITEMIZE(x, y)                                                   \
  do                                                                    \
  {                                                                     \
    Parse_context pc(YYTHD, Select);                                    \
    if (YYTHD->is_error() ||                                            \
        (YYTHD->lex->will_contextualize && (x)->itemize(&pc, (y))))     \
      MYSQL_YYABORT;                                                    \
  } while(0)


#define MAKE_CMD(x)                                    \
  do                                                   \
  {                                                    \
    if (YYTHD->is_error() || Lex->make_sql_cmd(x))     \
      MYSQL_YYABORT;                                   \
  } while(0)


#define MAKE_CMD_DCL_DUMMY()                           \
  do                                                   \
  {                                                    \
    assert(Lex->m_sql_cmd == nullptr);                 \
    Lex->m_sql_cmd= NEW_PTN Sql_cmd_dcl_dummy();       \
    if (!Lex->m_sql_cmd)                               \
      MYSQL_YYABORT;                                   \
    ((Sql_cmd_dcl_dummy *) Lex->m_sql_cmd)             \
      ->set_sql_command_code(Lex->sql_command);        \
  } while(0)

#define MAKE_CMD_DDL_DUMMY()                           \
  do                                                   \
  {                                                    \
    assert(Lex->m_sql_cmd == nullptr);                 \
    Lex->m_sql_cmd= NEW_PTN Sql_cmd_ddl_dummy();       \
    if (!Lex->m_sql_cmd)                               \
      MYSQL_YYABORT;                                   \
    ((Sql_cmd_ddl_dummy *) Lex->m_sql_cmd)             \
      ->set_sql_command_code(Lex->sql_command);        \
  } while(0)


#ifndef NDEBUG
#define YYDEBUG 1
#else
#define YYDEBUG 0
#endif




static
void my_sql_parser_error(YYLTYPE *location,
                         THD *thd, Parse_tree_root **, const char *s)
{
  if (strcmp(s, "syntax error") == 0) {
    thd->syntax_error_at(*location);
  } else if (strcmp(s, "memory exhausted") == 0) {
    my_error(ER_DA_OOM, MYF(0));
  } else {
    
    assert(false);
    my_error(ER_UNKNOWN_ERROR, MYF(0));
  }
}


#ifndef NDEBUG
void turn_parser_debug_on()
{
  

  extern int yydebug;
  yydebug= 1;
}
#endif

static bool is_native_function(const LEX_STRING &name)
{
  if (find_native_function_builder(name) != nullptr)
    return true;

  if (is_lex_native_function(&name))
    return true;

  return false;
}




static void case_stmt_action_case(THD *thd)
{
  LEX *lex= thd->lex;
  sp_head *sp= lex->sphead;
  sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

  sp->m_parser_data.new_cont_backpatch();

  

  pctx->push_label(thd, EMPTY_CSTR, sp->instructions());
}



static bool case_stmt_action_then(THD *thd, LEX *lex)
{
  sp_head *sp= lex->sphead;
  sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

  sp_instr_jump *i =
    new (thd->mem_root) sp_instr_jump(sp->instructions(), pctx);

  if (!i || sp->add_instr(thd, i))
    return true;

  

  sp->m_parser_data.do_backpatch(pctx->pop_label(), sp->instructions());

  

  return sp->m_parser_data.add_backpatch_entry(i, pctx->last_label());
}



static void case_stmt_action_end_case(LEX *lex, bool simple)
{
  sp_head *sp= lex->sphead;
  sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

  
  sp->m_parser_data.do_backpatch(pctx->pop_label(), sp->instructions());

  if (simple)
    pctx->pop_case_expr_id();

  sp->m_parser_data.do_cont_backpatch(sp->instructions());
}


static void init_index_hints(List<Index_hint> *hints, index_hint_type type,
                             index_clause_map clause)
{
  List_iterator<Index_hint> it(*hints);
  Index_hint *hint;
  while ((hint= it++))
  {
    hint->type= type;
    hint->clause= clause;
  }
}

bool my_yyoverflow(short **a, YYSTYPE **b, YYLTYPE **c, ulong *yystacksize);

#include "sql/parse_tree_column_attrs.h"
#include "sql/parse_tree_handler.h"
#include "sql/parse_tree_items.h"
#include "sql/parse_tree_nodes.h"
#include "sql/parse_tree_partitions.h"

void warn_about_deprecated_national(THD *thd)
{
  if (native_strcasecmp(national_charset_info->csname, "utf8") == 0 ||
      native_strcasecmp(national_charset_info->csname, "utf8mb3") == 0)
    push_warning(thd, ER_DEPRECATED_NATIONAL);
}

void warn_about_deprecated_binary(THD *thd)
{
  push_deprecated_warn(thd, "BINARY as attribute of a type",
  "a CHARACTER SET clause with _bin collation");
}

void warn_on_deprecated_user_defined_collation(
    THD *thd, const LEX_STRING collation_name) {
  if (collation_name.length == 0)
    return;
  CHARSET_INFO *collation = mysqld_collation_get_by_name(collation_name.str);
  if (collation && !(collation->state & MY_CS_COMPILED)) {
    push_warning_printf(thd, Sql_condition::SL_WARNING,
                        ER_WARN_DEPRECATED_USER_DEFINED_COLLATIONS,
                        ER_THD(thd, ER_WARN_DEPRECATED_USER_DEFINED_COLLATIONS),
                        collation->m_coll_name);
  }
}


#define yysymbol_kind_t my_sql_parser_symbol_kind_t

%}

%start start_entry

%parse-param { class THD *YYTHD }
%parse-param { class Parse_tree_root **parse_tree }

%lex-param { class THD *YYTHD }
%define api.pure                                    
%define api.prefix {my_sql_parser_}



%expect 59





%token  ABORT_SYM 258                     
%token  ACCESSIBLE_SYM 259
%token<lexer.keyword> ACCOUNT_SYM 260
%token<lexer.keyword> ACTION 261                
%token  ADD 262                           
%token<lexer.keyword> ADDDATE_SYM 263           
%token<lexer.keyword> AFTER_SYM 264             
%token<lexer.keyword> AGAINST 265
%token<lexer.keyword> AGGREGATE_SYM 266
%token<lexer.keyword> ALGORITHM_SYM 267
%token  ALL 268                           
%token  ALTER 269                         
%token<lexer.keyword> ALWAYS_SYM 270
%token  OBSOLETE_TOKEN_271 271            
%token  ANALYZE_SYM 272
%token  AND_AND_SYM 273                   
%token  AND_SYM 274                       
%token<lexer.keyword> ANY_SYM 275               
%token  AS 276                            
%token  ASC 277                           
%token<lexer.keyword> ASCII_SYM 278             
%token  ASENSITIVE_SYM 279                
%token<lexer.keyword> AT_SYM 280                
%token<lexer.keyword> AUTOEXTEND_SIZE_SYM 281
%token<lexer.keyword> AUTO_INC 282
%token<lexer.keyword> AVG_ROW_LENGTH 283
%token<lexer.keyword> AVG_SYM 284               
%token<lexer.keyword> BACKUP_SYM 285
%token  BEFORE_SYM 286                    
%token<lexer.keyword> BEGIN_SYM 287             
%token  BETWEEN_SYM 288                   
%token  BIGINT_SYM 289                    
%token  BINARY_SYM 290                    
%token<lexer.keyword> BINLOG_SYM 291
%token  BIN_NUM 292
%token  BIT_AND_SYM 293                   
%token  BIT_OR_SYM 294                    
%token<lexer.keyword> BIT_SYM 295               
%token  BIT_XOR_SYM 296                   
%token  BLOB_SYM 297                      
%token<lexer.keyword> BLOCK_SYM 298
%token<lexer.keyword> BOOLEAN_SYM 299           
%token<lexer.keyword> BOOL_SYM 300
%token  BOTH 301                          
%token<lexer.keyword> BTREE_SYM 302
%token  BY 303                            
%token<lexer.keyword> BYTE_SYM 304
%token<lexer.keyword> CACHE_SYM 305
%token  CALL_SYM 306                      
%token  CASCADE 307                       
%token<lexer.keyword> CASCADED 308              
%token  CASE_SYM 309                      
%token  CAST_SYM 310                      
%token<lexer.keyword> CATALOG_NAME_SYM 311      
%token<lexer.keyword> CHAIN_SYM 312             
%token  CHANGE 313
%token<lexer.keyword> CHANGED 314
%token<lexer.keyword> CHANNEL_SYM 315
%token<lexer.keyword> CHARSET 316
%token  CHAR_SYM 317                      
%token<lexer.keyword> CHECKSUM_SYM 318
%token  CHECK_SYM 319                     
%token<lexer.keyword> CIPHER_SYM 320
%token<lexer.keyword> CLASS_ORIGIN_SYM 321      
%token<lexer.keyword> CLIENT_SYM 322
%token<lexer.keyword> CLOSE_SYM 323             
%token<lexer.keyword> COALESCE 324              
%token<lexer.keyword> CODE_SYM 325
%token  COLLATE_SYM 326                   
%token<lexer.keyword> COLLATION_SYM 327         
%token<lexer.keyword> COLUMNS 328
%token  COLUMN_SYM 329                    
%token<lexer.keyword> COLUMN_FORMAT_SYM 330
%token<lexer.keyword> COLUMN_NAME_SYM 331       
%token<lexer.keyword> COMMENT_SYM 332
%token<lexer.keyword> COMMITTED_SYM 333         
%token<lexer.keyword> COMMIT_SYM 334            
%token<lexer.keyword> COMPACT_SYM 335
%token<lexer.keyword> COMPLETION_SYM 336
%token<lexer.keyword> COMPRESSED_SYM 337
%token<lexer.keyword> COMPRESSION_SYM 338
%token<lexer.keyword> ENCRYPTION_SYM 339
%token<lexer.keyword> CONCURRENT 340
%token  CONDITION_SYM 341                 
%token<lexer.keyword> CONNECTION_SYM 342
%token<lexer.keyword> CONSISTENT_SYM 343
%token  CONSTRAINT 344                    
%token<lexer.keyword> CONSTRAINT_CATALOG_SYM 345 
%token<lexer.keyword> CONSTRAINT_NAME_SYM 346   
%token<lexer.keyword> CONSTRAINT_SCHEMA_SYM 347 
%token<lexer.keyword> CONTAINS_SYM 348          
%token<lexer.keyword> CONTEXT_SYM 349
%token  CONTINUE_SYM 350                  
%token  CONVERT_SYM 351                   
%token  COUNT_SYM 352                     
%token<lexer.keyword> CPU_SYM 353
%token  CREATE 354                        
%token  CROSS 355                         
%token<lexer.keyword> CUBE_SYM 356        
%token  CURDATE 357                       
%token<lexer.keyword> CURRENT_SYM 358           
%token  CURRENT_USER 359                  
%token  CURSOR_SYM 360                    
%token<lexer.keyword> CURSOR_NAME_SYM 361       
%token  CURTIME 362                       
%token  DATABASE 363
%token  DATABASES 364
%token<lexer.keyword> DATAFILE_SYM 365
%token<lexer.keyword> DATA_SYM 366              
%token<lexer.keyword> DATETIME_SYM 367          
%token  DATE_ADD_INTERVAL 368             
%token  DATE_SUB_INTERVAL 369             
%token<lexer.keyword> DATE_SYM 370              
%token  DAY_HOUR_SYM 371
%token  DAY_MICROSECOND_SYM 372
%token  DAY_MINUTE_SYM 373
%token  DAY_SECOND_SYM 374
%token<lexer.keyword> DAY_SYM 375               
%token<lexer.keyword> DEALLOCATE_SYM 376        
%token  DECIMAL_NUM 377
%token  DECIMAL_SYM 378                   
%token  DECLARE_SYM 379                   
%token  DEFAULT_SYM 380                   
%token<lexer.keyword> DEFAULT_AUTH_SYM 381      
%token<lexer.keyword> DEFINER_SYM 382
%token  DELAYED_SYM 383
%token<lexer.keyword> DELAY_KEY_WRITE_SYM 384
%token  DELETE_SYM 385                    
%token  DESC 386                          
%token  DESCRIBE 387                      
%token  OBSOLETE_TOKEN_388 388            
%token  DETERMINISTIC_SYM 389             
%token<lexer.keyword> DIAGNOSTICS_SYM 390       
%token<lexer.keyword> DIRECTORY_SYM 391
%token<lexer.keyword> DISABLE_SYM 392
%token<lexer.keyword> DISCARD_SYM 393           
%token<lexer.keyword> DISK_SYM 394
%token  DISTINCT 395                      
%token  DIV_SYM 396
%token  DOUBLE_SYM 397                    
%token<lexer.keyword> DO_SYM 398
%token  DROP 399                          
%token  DUAL_SYM 400
%token<lexer.keyword> DUMPFILE 401
%token<lexer.keyword> DUPLICATE_SYM 402
%token<lexer.keyword> DYNAMIC_SYM 403           
%token  EACH_SYM 404                      
%token  ELSE 405                          
%token  ELSEIF_SYM 406
%token<lexer.keyword> ENABLE_SYM 407
%token  ENCLOSED 408
%token<lexer.keyword> END 409                   
%token<lexer.keyword> ENDS_SYM 410
%token  END_OF_INPUT 411                  
%token<lexer.keyword> ENGINES_SYM 412
%token<lexer.keyword> ENGINE_SYM 413
%token<lexer.keyword> ENUM_SYM 414              
%token  EQ 415                            
%token  EQUAL_SYM 416                     
%token<lexer.keyword> ERROR_SYM 417
%token<lexer.keyword> ERRORS 418
%token  ESCAPED 419
%token<lexer.keyword> ESCAPE_SYM 420            
%token<lexer.keyword> EVENTS_SYM 421
%token<lexer.keyword> EVENT_SYM 422
%token<lexer.keyword> EVERY_SYM 423             
%token<lexer.keyword> EXCHANGE_SYM 424
%token<lexer.keyword> EXECUTE_SYM 425           
%token  EXISTS 426                        
%token  EXIT_SYM 427
%token<lexer.keyword> EXPANSION_SYM 428
%token<lexer.keyword> EXPIRE_SYM 429
%token<lexer.keyword> EXPORT_SYM 430
%token<lexer.keyword> EXTENDED_SYM 431
%token<lexer.keyword> EXTENT_SIZE_SYM 432
%token  EXTRACT_SYM 433                   
%token  FALSE_SYM 434                     
%token<lexer.keyword> FAST_SYM 435
%token<lexer.keyword> FAULTS_SYM 436
%token  FETCH_SYM 437                     
%token<lexer.keyword> FILE_SYM 438
%token<lexer.keyword> FILE_BLOCK_SIZE_SYM 439
%token<lexer.keyword> FILTER_SYM 440
%token<lexer.keyword> FIRST_SYM 441             
%token<lexer.keyword> FIXED_SYM 442
%token  FLOAT_NUM 443
%token  FLOAT_SYM 444                     
%token<lexer.keyword> FLUSH_SYM 445
%token<lexer.keyword> FOLLOWS_SYM 446           
%token  FORCE_SYM 447
%token  FOREIGN 448                       
%token  FOR_SYM 449                       
%token<lexer.keyword> FORMAT_SYM 450
%token<lexer.keyword> FOUND_SYM 451             
%token  FROM 452
%token<lexer.keyword> FULL 453                  
%token  FULLTEXT_SYM 454
%token  FUNCTION_SYM 455                  
%token  GE 456
%token<lexer.keyword> GENERAL 457
%token  GENERATED 458
%token<lexer.keyword> GROUP_REPLICATION 459
%token<lexer.keyword> GEOMETRYCOLLECTION_SYM 460 
%token<lexer.keyword> GEOMETRY_SYM 461
%token<lexer.keyword> GET_FORMAT 462            
%token  GET_SYM 463                       
%token<lexer.keyword> GLOBAL_SYM 464            
%token  GRANT 465                         
%token<lexer.keyword> GRANTS 466
%token  GROUP_SYM 467                     
%token  GROUP_CONCAT_SYM 468
%token  GT_SYM 469                        
%token<lexer.keyword> HANDLER_SYM 470
%token<lexer.keyword> HASH_SYM 471
%token  HAVING 472                        
%token<lexer.keyword> HELP_SYM 473
%token  HEX_NUM 474
%token  HIGH_PRIORITY 475
%token<lexer.keyword> HOST_SYM 476
%token<lexer.keyword> HOSTS_SYM 477
%token  HOUR_MICROSECOND_SYM 478
%token  HOUR_MINUTE_SYM 479
%token  HOUR_SECOND_SYM 480
%token<lexer.keyword> HOUR_SYM 481              
%token  IDENT 482
%token<lexer.keyword> IDENTIFIED_SYM 483
%token  IDENT_QUOTED 484
%token  IF 485
%token  IGNORE_SYM 486
%token<lexer.keyword> IGNORE_SERVER_IDS_SYM 487
%token<lexer.keyword> IMPORT 488
%token<lexer.keyword> INDEXES 489
%token  INDEX_SYM 490
%token  INFILE_SYM 491
%token<lexer.keyword> INITIAL_SIZE_SYM 492
%token  INNER_SYM 493                     
%token  INOUT_SYM 494                     
%token  INSENSITIVE_SYM 495               
%token  INSERT_SYM 496                    
%token<lexer.keyword> INSERT_METHOD 497
%token<lexer.keyword> INSTANCE_SYM 498
%token<lexer.keyword> INSTALL_SYM 499
%token  INTERVAL_SYM 500                  
%token  INTO 501                          
%token  INT_SYM 502                       
%token<lexer.keyword> INVOKER_SYM 503
%token  IN_SYM 504                        
%token  IO_AFTER_GTIDS 505                
%token  IO_BEFORE_GTIDS 506               
%token<lexer.keyword> IO_SYM 507
%token<lexer.keyword> IPC_SYM 508
%token  IS 509                            
%token<lexer.keyword> ISOLATION 510             
%token<lexer.keyword> ISSUER_SYM 511
%token  ITERATE_SYM 512
%token  JOIN_SYM 513                      
%token  JSON_SEPARATOR_SYM 514            
%token<lexer.keyword> JSON_SYM 515              
%token  KEYS 516
%token<lexer.keyword> KEY_BLOCK_SIZE 517
%token  KEY_SYM 518                       
%token  KILL_SYM 519
%token<lexer.keyword> LANGUAGE_SYM 520          
%token<lexer.keyword> LAST_SYM 521              
%token  LE 522                            
%token  LEADING 523                       
%token<lexer.keyword> LEAVES 524
%token  LEAVE_SYM 525
%token  LEFT 526                          
%token<lexer.keyword> LESS_SYM 527
%token<lexer.keyword> LEVEL_SYM 528
%token  LEX_HOSTNAME 529
%token  LIKE 530                          
%token  LIMIT 531
%token  LINEAR_SYM 532
%token  LINES 533
%token<lexer.keyword> LINESTRING_SYM 534        
%token<lexer.keyword> LIST_SYM 535
%token  LOAD 536
%token<lexer.keyword> LOCAL_SYM 537             
%token  OBSOLETE_TOKEN_538 538            
%token<lexer.keyword> LOCKS_SYM 539
%token  LOCK_SYM 540
%token<lexer.keyword> LOGFILE_SYM 541
%token<lexer.keyword> LOGS_SYM 542
%token  LONGBLOB_SYM 543                  
%token  LONGTEXT_SYM 544                  
%token  LONG_NUM 545
%token  LONG_SYM 546
%token  LOOP_SYM 547
%token  LOW_PRIORITY 548
%token  LT 549                            
%token<lexer.keyword> OBSOLETE_TOKEN_550 550 
%token OBSOLETE_TOKEN_551 551 
%token<lexer.keyword> OBSOLETE_TOKEN_552 552 
%token<lexer.keyword> OBSOLETE_TOKEN_553 553 
%token<lexer.keyword> OBSOLETE_TOKEN_554 554 
%token<lexer.keyword> OBSOLETE_TOKEN_555 555 
%token<lexer.keyword> OBSOLETE_TOKEN_556 556 
%token<lexer.keyword> OBSOLETE_TOKEN_557 557 
%token<lexer.keyword> OBSOLETE_TOKEN_558 558 
%token<lexer.keyword> OBSOLETE_TOKEN_559 559 
 
%token<lexer.keyword> OBSOLETE_TOKEN_561 561 
%token<lexer.keyword> OBSOLETE_TOKEN_562 562 
%token<lexer.keyword> OBSOLETE_TOKEN_563 563 
%token<lexer.keyword> OBSOLETE_TOKEN_564 564 
%token<lexer.keyword> OBSOLETE_TOKEN_565 565 
%token<lexer.keyword> OBSOLETE_TOKEN_566 566 
%token<lexer.keyword> OBSOLETE_TOKEN_567 567 
%token<lexer.keyword> OBSOLETE_TOKEN_568 568 
%token<lexer.keyword> OBSOLETE_TOKEN_569 569 
%token  OBSOLETE_TOKEN_570 570 
%token<lexer.keyword> MASTER_SYM 571
%token<lexer.keyword> OBSOLETE_TOKEN_572 572 
%token<lexer.keyword> OBSOLETE_TOKEN_573 573 
%token  MATCH 574                         
%token<lexer.keyword> MAX_CONNECTIONS_PER_HOUR 575
%token<lexer.keyword> MAX_QUERIES_PER_HOUR 576
%token<lexer.keyword> MAX_ROWS 577
%token<lexer.keyword> MAX_SIZE_SYM 578
%token  MAX_SYM 579                       
%token<lexer.keyword> MAX_UPDATES_PER_HOUR 580
%token<lexer.keyword> MAX_USER_CONNECTIONS_SYM 581
%token  MAX_VALUE_SYM 582                 
%token  MEDIUMBLOB_SYM 583                
%token  MEDIUMINT_SYM 584                 
%token  MEDIUMTEXT_SYM 585                
%token<lexer.keyword> MEDIUM_SYM 586
%token<lexer.keyword> MEMORY_SYM 587
%token<lexer.keyword> MERGE_SYM 588             
%token<lexer.keyword> MESSAGE_TEXT_SYM 589      
%token<lexer.keyword> MICROSECOND_SYM 590       
%token<lexer.keyword> MIGRATE_SYM 591
%token  MINUTE_MICROSECOND_SYM 592
%token  MINUTE_SECOND_SYM 593
%token<lexer.keyword> MINUTE_SYM 594            
%token<lexer.keyword> MIN_ROWS 595
%token  MIN_SYM 596                       
%token<lexer.keyword> MODE_SYM 597
%token  MODIFIES_SYM 598                  
%token<lexer.keyword> MODIFY_SYM 599
%token  MOD_SYM 600                       
%token<lexer.keyword> MONTH_SYM 601             
%token<lexer.keyword> MULTILINESTRING_SYM 602   
%token<lexer.keyword> MULTIPOINT_SYM 603        
%token<lexer.keyword> MULTIPOLYGON_SYM 604      
%token<lexer.keyword> MUTEX_SYM 605
%token<lexer.keyword> MYSQL_ERRNO_SYM 606
%token<lexer.keyword> NAMES_SYM 607             
%token<lexer.keyword> NAME_SYM 608              
%token<lexer.keyword> NATIONAL_SYM 609          
%token  NATURAL 610                       
%token  NCHAR_STRING 611
%token<lexer.keyword> NCHAR_SYM 612             
%token<lexer.keyword> NDBCLUSTER_SYM 613
%token  NE 614                            
%token  NEG 615
%token<lexer.keyword> NEVER_SYM 616
%token<lexer.keyword> NEW_SYM 617               
%token<lexer.keyword> NEXT_SYM 618              
%token<lexer.keyword> NODEGROUP_SYM 619
%token<lexer.keyword> NONE_SYM 620              
%token  NOT2_SYM 621
%token  NOT_SYM 622                       
%token  NOW_SYM 623
%token<lexer.keyword> NO_SYM 624                
%token<lexer.keyword> NO_WAIT_SYM 625
%token  NO_WRITE_TO_BINLOG 626
%token  NULL_SYM 627                      
%token  NUM 628
%token<lexer.keyword> NUMBER_SYM 629            
%token  NUMERIC_SYM 630                   
%token<lexer.keyword> NVARCHAR_SYM 631
%token<lexer.keyword> OFFSET_SYM 632
%token  ON_SYM 633                        
%token<lexer.keyword> ONE_SYM 634
%token<lexer.keyword> ONLY_SYM 635              
%token<lexer.keyword> OPEN_SYM 636              
%token  OPTIMIZE 637
%token  OPTIMIZER_COSTS_SYM 638
%token<lexer.keyword> OPTIONS_SYM 639
%token  OPTION 640                        
%token  OPTIONALLY 641
%token  OR2_SYM 642
%token  ORDER_SYM 643                     
%token  OR_OR_SYM 644                     
%token  OR_SYM 645                        
%token  OUTER_SYM 646
%token  OUTFILE 647
%token  OUT_SYM 648                       
%token<lexer.keyword> OWNER_SYM 649
%token<lexer.keyword> PACK_KEYS_SYM 650
%token<lexer.keyword> PAGE_SYM 651
%token  PARAM_MARKER 652
%token<lexer.keyword> PARSER_SYM 653
%token  OBSOLETE_TOKEN_654 654            
%token<lexer.keyword> PARTIAL 655                       
%token  PARTITION_SYM 656                 
%token<lexer.keyword> PARTITIONS_SYM 657
%token<lexer.keyword> PARTITIONING_SYM 658
%token<lexer.keyword> PASSWORD 659
%token<lexer.keyword> PHASE_SYM 660
%token<lexer.keyword> PLUGIN_DIR_SYM 661        
%token<lexer.keyword> PLUGIN_SYM 662
%token<lexer.keyword> PLUGINS_SYM 663
%token<lexer.keyword> POINT_SYM 664
%token<lexer.keyword> POLYGON_SYM 665           
%token<lexer.keyword> PORT_SYM 666
%token  POSITION_SYM 667                  
%token<lexer.keyword> PRECEDES_SYM 668          
%token  PRECISION 669                     
%token<lexer.keyword> PREPARE_SYM 670           
%token<lexer.keyword> PRESERVE_SYM 671
%token<lexer.keyword> PREV_SYM 672
%token  PRIMARY_SYM 673                   
%token<lexer.keyword> PRIVILEGES 674            
%token  PROCEDURE_SYM 675                 
%token<lexer.keyword> PROCESS 676
%token<lexer.keyword> PROCESSLIST_SYM 677
%token<lexer.keyword> PROFILE_SYM 678
%token<lexer.keyword> PROFILES_SYM 679
%token<lexer.keyword> PROXY_SYM 680
%token  PURGE 681
%token<lexer.keyword> QUARTER_SYM 682
%token<lexer.keyword> QUERY_SYM 683
%token<lexer.keyword> QUICK 684
%token  RANGE_SYM 685                     
%token  READS_SYM 686                     
%token<lexer.keyword> READ_ONLY_SYM 687
%token  READ_SYM 688                      
%token  READ_WRITE_SYM 689
%token  REAL_SYM 690                      
%token<lexer.keyword> REBUILD_SYM 691
%token<lexer.keyword> RECOVER_SYM 692
%token  OBSOLETE_TOKEN_693 693            
%token<lexer.keyword> REDO_BUFFER_SIZE_SYM 694
%token<lexer.keyword> REDUNDANT_SYM 695
%token  REFERENCES 696                    
%token  REGEXP 697
%token<lexer.keyword> RELAY 698
%token<lexer.keyword> RELAYLOG_SYM 699
%token<lexer.keyword> RELAY_LOG_FILE_SYM 700
%token<lexer.keyword> RELAY_LOG_POS_SYM 701
%token<lexer.keyword> RELAY_THREAD 702
%token  RELEASE_SYM 703                   
%token<lexer.keyword> RELOAD 704
%token<lexer.keyword> REMOVE_SYM 705
%token  RENAME 706
%token<lexer.keyword> REORGANIZE_SYM 707
%token<lexer.keyword> REPAIR 708
%token<lexer.keyword> REPEATABLE_SYM 709        
%token  REPEAT_SYM 710                    
%token  REPLACE_SYM 711                   
%token<lexer.keyword> REPLICATION 712
%token<lexer.keyword> REPLICATE_DO_DB 713
%token<lexer.keyword> REPLICATE_IGNORE_DB 714
%token<lexer.keyword> REPLICATE_DO_TABLE 715
%token<lexer.keyword> REPLICATE_IGNORE_TABLE 716
%token<lexer.keyword> REPLICATE_WILD_DO_TABLE 717
%token<lexer.keyword> REPLICATE_WILD_IGNORE_TABLE 718
%token<lexer.keyword> REPLICATE_REWRITE_DB 719
%token  REQUIRE_SYM 720
%token<lexer.keyword> RESET_SYM 721
%token  RESIGNAL_SYM 722                  
%token<lexer.keyword> RESOURCES 723
%token<lexer.keyword> RESTORE_SYM 724
%token  RESTRICT 725
%token<lexer.keyword> RESUME_SYM 726
%token<lexer.keyword> RETURNED_SQLSTATE_SYM 727 
%token<lexer.keyword> RETURNS_SYM 728           
%token  RETURN_SYM 729                    
%token<lexer.keyword> REVERSE_SYM 730
%token  REVOKE 731                        
%token  RIGHT 732                         
%token<lexer.keyword> ROLLBACK_SYM 733          
%token<lexer.keyword> ROLLUP_SYM 734            
%token<lexer.keyword> ROTATE_SYM 735
%token<lexer.keyword> ROUTINE_SYM 736           
%token  ROWS_SYM 737                      
%token<lexer.keyword> ROW_FORMAT_SYM 738
%token  ROW_SYM 739                       
%token<lexer.keyword> ROW_COUNT_SYM 740         
%token<lexer.keyword> RTREE_SYM 741
%token<lexer.keyword> SAVEPOINT_SYM 742         
%token<lexer.keyword> SCHEDULE_SYM 743
%token<lexer.keyword> SCHEMA_NAME_SYM 744       
%token  SECOND_MICROSECOND_SYM 745
%token<lexer.keyword> SECOND_SYM 746            
%token<lexer.keyword> SECURITY_SYM 747          
%token  SELECT_SYM 748                    
%token  SENSITIVE_SYM 749                 
%token  SEPARATOR_SYM 750
%token<lexer.keyword> SERIALIZABLE_SYM 751      
%token<lexer.keyword> SERIAL_SYM 752
%token<lexer.keyword> SESSION_SYM 753           
%token<lexer.keyword> SERVER_SYM 754
%token  OBSOLETE_TOKEN_755 755            
%token  SET_SYM 756                       
%token  SET_VAR 757
%token<lexer.keyword> SHARE_SYM 758
%token  SHIFT_LEFT 759                    
%token  SHIFT_RIGHT 760                   
%token  SHOW 761
%token<lexer.keyword> SHUTDOWN 762
%token  SIGNAL_SYM 763                    
%token<lexer.keyword> SIGNED_SYM 764
%token<lexer.keyword> SIMPLE_SYM 765            
%token<lexer.keyword> SLAVE 766
%token<lexer.keyword> SLOW 767
%token  SMALLINT_SYM 768                  
%token<lexer.keyword> SNAPSHOT_SYM 769
%token<lexer.keyword> SOCKET_SYM 770
%token<lexer.keyword> SONAME_SYM 771
%token<lexer.keyword> SOUNDS_SYM 772
%token<lexer.keyword> SOURCE_SYM 773
%token  SPATIAL_SYM 774
%token  SPECIFIC_SYM 775                  
%token  SQLEXCEPTION_SYM 776              
%token  SQLSTATE_SYM 777                  
%token  SQLWARNING_SYM 778                
%token<lexer.keyword> SQL_AFTER_GTIDS 779       
%token<lexer.keyword> SQL_AFTER_MTS_GAPS 780    
%token<lexer.keyword> SQL_BEFORE_GTIDS 781      
%token  SQL_BIG_RESULT 782
%token<lexer.keyword> SQL_BUFFER_RESULT 783
%token  OBSOLETE_TOKEN_784 784            
%token  SQL_CALC_FOUND_ROWS 785
%token<lexer.keyword> SQL_NO_CACHE_SYM 786
%token  SQL_SMALL_RESULT 787
%token  SQL_SYM 788                       
%token<lexer.keyword> SQL_THREAD 789
%token  SSL_SYM 790
%token<lexer.keyword> STACKED_SYM 791           
%token  STARTING 792
%token<lexer.keyword> STARTS_SYM 793
%token<lexer.keyword> START_SYM 794             
%token<lexer.keyword> STATS_AUTO_RECALC_SYM 795
%token<lexer.keyword> STATS_PERSISTENT_SYM 796
%token<lexer.keyword> STATS_SAMPLE_PAGES_SYM 797
%token<lexer.keyword> STATUS_SYM 798
%token  STDDEV_SAMP_SYM 799               
%token  STD_SYM 800
%token<lexer.keyword> STOP_SYM 801
%token<lexer.keyword> STORAGE_SYM 802
%token  STORED_SYM 803
%token  STRAIGHT_JOIN 804
%token<lexer.keyword> STRING_SYM 805
%token<lexer.keyword> SUBCLASS_ORIGIN_SYM 806   
%token<lexer.keyword> SUBDATE_SYM 807
%token<lexer.keyword> SUBJECT_SYM 808
%token<lexer.keyword> SUBPARTITIONS_SYM 809
%token<lexer.keyword> SUBPARTITION_SYM 810
%token  SUBSTRING 811                     
%token  SUM_SYM 812                       
%token<lexer.keyword> SUPER_SYM 813
%token<lexer.keyword> SUSPEND_SYM 814
%token<lexer.keyword> SWAPS_SYM 815
%token<lexer.keyword> SWITCHES_SYM 816
%token  SYSDATE 817
%token<lexer.keyword> TABLES 818
%token<lexer.keyword> TABLESPACE_SYM 819
%token  OBSOLETE_TOKEN_820 820            
%token  TABLE_SYM 821                     
%token<lexer.keyword> TABLE_CHECKSUM_SYM 822
%token<lexer.keyword> TABLE_NAME_SYM 823        
%token<lexer.keyword> TEMPORARY 824             
%token<lexer.keyword> TEMPTABLE_SYM 825
%token  TERMINATED 826
%token  TEXT_STRING 827
%token<lexer.keyword> TEXT_SYM 828
%token<lexer.keyword> THAN_SYM 829
%token  THEN_SYM 830                      
%token<lexer.keyword> TIMESTAMP_SYM 831         
%token<lexer.keyword> TIMESTAMP_ADD 832
%token<lexer.keyword> TIMESTAMP_DIFF 833
%token<lexer.keyword> TIME_SYM 834              
%token  TINYBLOB_SYM 835                  
%token  TINYINT_SYM 836                   
%token  TINYTEXT_SYN 837                  
%token  TO_SYM 838                        
%token  TRAILING 839                      
%token<lexer.keyword> TRANSACTION_SYM 840
%token<lexer.keyword> TRIGGERS_SYM 841
%token  TRIGGER_SYM 842                   
%token  TRIM 843                          
%token  TRUE_SYM 844                      
%token<lexer.keyword> TRUNCATE_SYM 845
%token<lexer.keyword> TYPES_SYM 846
%token<lexer.keyword> TYPE_SYM 847              
%token  OBSOLETE_TOKEN_848 848            
%token  ULONGLONG_NUM 849
%token<lexer.keyword> UNCOMMITTED_SYM 850       
%token<lexer.keyword> UNDEFINED_SYM 851
%token  UNDERSCORE_CHARSET 852
%token<lexer.keyword> UNDOFILE_SYM 853
%token<lexer.keyword> UNDO_BUFFER_SIZE_SYM 854
%token  UNDO_SYM 855                      
%token<lexer.keyword> UNICODE_SYM 856
%token<lexer.keyword> UNINSTALL_SYM 857
%token  UNION_SYM 858                     
%token  UNIQUE_SYM 859
%token<lexer.keyword> UNKNOWN_SYM 860           
%token  UNLOCK_SYM 861
%token  UNSIGNED_SYM 862                  
%token<lexer.keyword> UNTIL_SYM 863
%token  UPDATE_SYM 864                    
%token<lexer.keyword> UPGRADE_SYM 865
%token  USAGE 866                         
%token<lexer.keyword> USER 867                  
%token<lexer.keyword> USE_FRM 868
%token  USE_SYM 869
%token  USING 870                         
%token  UTC_DATE_SYM 871
%token  UTC_TIMESTAMP_SYM 872
%token  UTC_TIME_SYM 873
%token<lexer.keyword> VALIDATION_SYM 874        
%token  VALUES 875                        
%token<lexer.keyword> VALUE_SYM 876             
%token  VARBINARY_SYM 877                 
%token  VARCHAR_SYM 878                   
%token<lexer.keyword> VARIABLES 879
%token  VARIANCE_SYM 880
%token  VARYING 881                       
%token  VAR_SAMP_SYM 882
%token<lexer.keyword> VIEW_SYM 883              
%token  VIRTUAL_SYM 884
%token<lexer.keyword> WAIT_SYM 885
%token<lexer.keyword> WARNINGS 886
%token<lexer.keyword> WEEK_SYM 887
%token<lexer.keyword> WEIGHT_STRING_SYM 888
%token  WHEN_SYM 889                      
%token  WHERE 890                         
%token  WHILE_SYM 891
%token  WITH 892                          
%token  OBSOLETE_TOKEN_893 893            
%token  WITH_ROLLUP_SYM 894               
%token<lexer.keyword> WITHOUT_SYM 895           
%token<lexer.keyword> WORK_SYM 896              
%token<lexer.keyword> WRAPPER_SYM 897
%token  WRITE_SYM 898                     
%token<lexer.keyword> X509_SYM 899
%token<lexer.keyword> XA_SYM 900
%token<lexer.keyword> XID_SYM 901               
%token<lexer.keyword> XML_SYM 902
%token  XOR 903
%token  YEAR_MONTH_SYM 904
%token<lexer.keyword> YEAR_SYM 905              
%token  ZEROFILL_SYM 906                  


%token  JSON_UNQUOTED_SEPARATOR_SYM 907   
%token<lexer.keyword> PERSIST_SYM 908           
%token<lexer.keyword> ROLE_SYM 909              
%token<lexer.keyword> ADMIN_SYM 910             
%token<lexer.keyword> INVISIBLE_SYM 911
%token<lexer.keyword> VISIBLE_SYM 912
%token  EXCEPT_SYM 913                    
%token<lexer.keyword> COMPONENT_SYM 914         
%token  RECURSIVE_SYM 915                 
%token  GRAMMAR_SELECTOR_EXPR 916         
%token  GRAMMAR_SELECTOR_GCOL 917       
%token  GRAMMAR_SELECTOR_PART 918      
%token  GRAMMAR_SELECTOR_CTE 919             
%token  JSON_OBJECTAGG 920                
%token  JSON_ARRAYAGG 921                 
%token  OF_SYM 922                        
%token<lexer.keyword> SKIP_SYM 923              
%token<lexer.keyword> LOCKED_SYM 924            
%token<lexer.keyword> NOWAIT_SYM 925            
%token  GROUPING_SYM 926                  
%token<lexer.keyword> PERSIST_ONLY_SYM 927      
%token<lexer.keyword> HISTOGRAM_SYM 928         
%token<lexer.keyword> BUCKETS_SYM 929           
%token<lexer.keyword> OBSOLETE_TOKEN_930 930    
%token<lexer.keyword> CLONE_SYM 931             
%token  CUME_DIST_SYM 932                 
%token  DENSE_RANK_SYM 933                
%token<lexer.keyword> EXCLUDE_SYM 934           
%token  FIRST_VALUE_SYM 935               
%token<lexer.keyword> FOLLOWING_SYM 936         
%token  GROUPS_SYM 937                    
%token  LAG_SYM 938                       
%token  LAST_VALUE_SYM 939                
%token  LEAD_SYM 940                      
%token  NTH_VALUE_SYM 941                 
%token  NTILE_SYM 942                     
%token<lexer.keyword> NULLS_SYM 943             
%token<lexer.keyword> OTHERS_SYM 944            
%token  OVER_SYM 945                      
%token  PERCENT_RANK_SYM 946              
%token<lexer.keyword> PRECEDING_SYM 947         
%token  RANK_SYM 948                      
%token<lexer.keyword> RESPECT_SYM 949           
%token  ROW_NUMBER_SYM 950                
%token<lexer.keyword> TIES_SYM 951              
%token<lexer.keyword> UNBOUNDED_SYM 952         
%token  WINDOW_SYM 953                    
%token  EMPTY_SYM 954                     
%token  JSON_TABLE_SYM 955                
%token<lexer.keyword> NESTED_SYM 956            
%token<lexer.keyword> ORDINALITY_SYM 957        
%token<lexer.keyword> PATH_SYM 958              
%token<lexer.keyword> HISTORY_SYM 959           
%token<lexer.keyword> REUSE_SYM 960             
%token<lexer.keyword> SRID_SYM 961              
%token<lexer.keyword> THREAD_PRIORITY_SYM 962   
%token<lexer.keyword> RESOURCE_SYM 963          
%token  SYSTEM_SYM 964                    
%token<lexer.keyword> VCPU_SYM 965              
%token<lexer.keyword> OBSOLETE_TOKEN_966 966    
%token<lexer.keyword> OBSOLETE_TOKEN_967 967    
%token<lexer.keyword> RESTART_SYM 968                   
%token<lexer.keyword> DEFINITION_SYM 969                
%token<lexer.keyword> DESCRIPTION_SYM 970               
%token<lexer.keyword> ORGANIZATION_SYM 971              
%token<lexer.keyword> REFERENCE_SYM 972                 
%token<lexer.keyword> ACTIVE_SYM 973                    
%token<lexer.keyword> INACTIVE_SYM 974                  
%token          LATERAL_SYM 975                   
%token<lexer.keyword> ARRAY_SYM 976                     
%token<lexer.keyword> MEMBER_SYM 977                    
%token<lexer.keyword> OPTIONAL_SYM 978                  
%token<lexer.keyword> SECONDARY_SYM 979                 
%token<lexer.keyword> SECONDARY_ENGINE_SYM 980          
%token<lexer.keyword> SECONDARY_LOAD_SYM 981            
%token<lexer.keyword> SECONDARY_UNLOAD_SYM 982          
%token<lexer.keyword> RETAIN_SYM 983                    
%token<lexer.keyword> OLD_SYM 984                       
%token<lexer.keyword> ENFORCED_SYM 985                  
%token<lexer.keyword> OJ_SYM 986                        
%token<lexer.keyword> NETWORK_NAMESPACE_SYM 987         
%token<lexer.keyword> RANDOM_SYM 988                    
%token<lexer.keyword> OBSOLETE_TOKEN_989 989 
%token<lexer.keyword> OBSOLETE_TOKEN_990 990  
%token<lexer.keyword> PRIVILEGE_CHECKS_USER_SYM 991     
%token<lexer.keyword> OBSOLETE_TOKEN_992 992   
%token<lexer.keyword> REQUIRE_ROW_FORMAT_SYM 993        
%token<lexer.keyword> PASSWORD_LOCK_TIME_SYM 994        
%token<lexer.keyword> FAILED_LOGIN_ATTEMPTS_SYM 995     
%token<lexer.keyword> REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYM 996 
%token<lexer.keyword> STREAM_SYM 997                    
%token<lexer.keyword> OFF_SYM 998                       
%token<lexer.keyword> RETURNING_SYM 999                 

%token YYUNDEF 1150                
%token<lexer.keyword> JSON_VALUE_SYM 1151               
%token<lexer.keyword> TLS_SYM 1152                      
%token<lexer.keyword> ATTRIBUTE_SYM 1153                

%token<lexer.keyword> ENGINE_ATTRIBUTE_SYM 1154         
%token<lexer.keyword> SECONDARY_ENGINE_ATTRIBUTE_SYM 1155 
%token<lexer.keyword> SOURCE_CONNECTION_AUTO_FAILOVER_SYM 1156 
%token<lexer.keyword> ZONE_SYM 1157                     
%token<lexer.keyword> GRAMMAR_SELECTOR_DERIVED_EXPR 1158  
%token<lexer.keyword> REPLICA_SYM 1159
%token<lexer.keyword> REPLICAS_SYM 1160
%token<lexer.keyword> ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS_SYM 1161      
%token<lexer.keyword> GET_SOURCE_PUBLIC_KEY_SYM 1162           
%token<lexer.keyword> SOURCE_AUTO_POSITION_SYM 1163            
%token<lexer.keyword> SOURCE_BIND_SYM 1164                     
%token<lexer.keyword> SOURCE_COMPRESSION_ALGORITHM_SYM 1165    
%token<lexer.keyword> SOURCE_CONNECT_RETRY_SYM 1166            
%token<lexer.keyword> SOURCE_DELAY_SYM 1167                    
%token<lexer.keyword> SOURCE_HEARTBEAT_PERIOD_SYM 1168         
%token<lexer.keyword> SOURCE_HOST_SYM 1169                     
%token<lexer.keyword> SOURCE_LOG_FILE_SYM 1170                 
%token<lexer.keyword> SOURCE_LOG_POS_SYM 1171                  
%token<lexer.keyword> SOURCE_PASSWORD_SYM 1172                 
%token<lexer.keyword> SOURCE_PORT_SYM 1173                     
%token<lexer.keyword> SOURCE_PUBLIC_KEY_PATH_SYM 1174          
%token<lexer.keyword> SOURCE_RETRY_COUNT_SYM 1175              
%token<lexer.keyword> SOURCE_SSL_SYM 1176                      
%token<lexer.keyword> SOURCE_SSL_CA_SYM 1177                   
%token<lexer.keyword> SOURCE_SSL_CAPATH_SYM 1178               
%token<lexer.keyword> SOURCE_SSL_CERT_SYM 1179                 
%token<lexer.keyword> SOURCE_SSL_CIPHER_SYM 1180               
%token<lexer.keyword> SOURCE_SSL_CRL_SYM 1181                  
%token<lexer.keyword> SOURCE_SSL_CRLPATH_SYM 1182              
%token<lexer.keyword> SOURCE_SSL_KEY_SYM 1183                  
%token<lexer.keyword> SOURCE_SSL_VERIFY_SERVER_CERT_SYM 1184   
%token<lexer.keyword> SOURCE_TLS_CIPHERSUITES_SYM 1185         
%token<lexer.keyword> SOURCE_TLS_VERSION_SYM 1186              
%token<lexer.keyword> SOURCE_USER_SYM 1187                     
%token<lexer.keyword> SOURCE_ZSTD_COMPRESSION_LEVEL_SYM 1188   

%token<lexer.keyword> ST_COLLECT_SYM 1189                      
%token<lexer.keyword> KEYRING_SYM 1190                         

%token<lexer.keyword> AUTHENTICATION_SYM         1191      
%token<lexer.keyword> FACTOR_SYM                 1192      
%token<lexer.keyword> FINISH_SYM                 1193      
%token<lexer.keyword> INITIATE_SYM               1194      
%token<lexer.keyword> REGISTRATION_SYM           1195      
%token<lexer.keyword> UNREGISTER_SYM             1196      
%token<lexer.keyword> INITIAL_SYM                1197      
%token<lexer.keyword> CHALLENGE_RESPONSE_SYM     1198      

%token<lexer.keyword> GTID_ONLY_SYM 1199                   

%token                INTERSECT_SYM 1200                     

%token<lexer.keyword> BULK_SYM                   1201  
%token<lexer.keyword> URL_SYM                    1202   
%token<lexer.keyword> GENERATE_SYM               1203   

%token                DOLLAR_QUOTED_STRING_SYM   1204   

%token<lexer.keyword> PARSE_TREE_SYM             1205   

%token<lexer.keyword> LOG_SYM                    1206   
%token<lexer.keyword> GTIDS_SYM                  1207   

%token<lexer.keyword> PARALLEL_SYM       1208      
%token<lexer.keyword> S3_SYM             1209      
%token<lexer.keyword> QUALIFY_SYM        1210      

%token<lexer.keyword> AUTO_SYM                   1211   
%token<lexer.keyword> MANUAL_SYM                 1212   
%token<lexer.keyword> BERNOULLI_SYM              1213  
%token<lexer.keyword> TABLESAMPLE_SYM            1214  




%left KEYWORD_USED_AS_IDENT
%nonassoc TEXT_STRING
%left KEYWORD_USED_AS_KEYWORD



%right UNIQUE_SYM KEY_SYM

%left UNION_SYM EXCEPT_SYM
%left INTERSECT_SYM
%left CONDITIONLESS_JOIN
%left   JOIN_SYM INNER_SYM CROSS STRAIGHT_JOIN NATURAL LEFT RIGHT ON_SYM USING
%left   SET_VAR
%left   OR_SYM OR2_SYM
%left   XOR
%left   AND_SYM AND_AND_SYM
%left   BETWEEN_SYM CASE_SYM WHEN_SYM THEN_SYM ELSE
%left   EQ EQUAL_SYM GE GT_SYM LE LT NE IS LIKE REGEXP IN_SYM
%left   '|'
%left   '&'
%left   SHIFT_LEFT SHIFT_RIGHT
%left   '-' '+'
%left   '*' '/' '%' DIV_SYM MOD_SYM
%left   '^'
%left   OR_OR_SYM
%left   NEG '~'
%right  NOT_SYM NOT2_SYM
%right  BINARY_SYM COLLATE_SYM
%left  INTERVAL_SYM
%left  PREFER_PARENTHESES
%left '(' ')'

%left EMPTY_FROM_CLAUSE
%right INTO

%type <lexer.lex_str>
        IDENT IDENT_QUOTED TEXT_STRING DECIMAL_NUM FLOAT_NUM NUM LONG_NUM HEX_NUM
        LEX_HOSTNAME ULONGLONG_NUM select_alias ident opt_ident ident_or_text
        role_ident role_ident_or_text
        IDENT_sys TEXT_STRING_sys TEXT_STRING_literal DOLLAR_QUOTED_STRING_SYM
        NCHAR_STRING
        BIN_NUM TEXT_STRING_filesystem ident_or_empty
        TEXT_STRING_sys_nonewline TEXT_STRING_password TEXT_STRING_hash
        TEXT_STRING_validated
        filter_wild_db_table_string
        opt_constraint_name
        ts_datafile lg_undofile  opt_logfile_group_name opt_ts_datafile_name
        opt_describe_column
        opt_datadir_ssl default_encryption
        lvalue_ident
        schema
        engine_or_all
        opt_binlog_in
        persisted_variable_ident
        routine_string
        opt_explain_into

%type <lex_cstr>
        key_cache_name
        label_ident
        opt_table_alias
        opt_replace_password
        sp_opt_label
        json_attribute
        opt_channel
        opt_explain_for_schema
        opt_compression_algorithm

%type <lex_str_list> TEXT_STRING_sys_list

%type <table>
        table_ident

%type <simple_string>
        opt_db

%type <string>
        text_string opt_gconcat_separator
        opt_xml_rows_identified_by

%type <num>
        lock_option
        udf_type if_exists
        opt_no_write_to_binlog
        all_or_any opt_distinct
        fulltext_options union_option
        transaction_access_mode_types
        opt_natural_language_mode opt_query_expansion
        opt_ev_status opt_ev_on_completion ev_on_completion opt_ev_comment
        ev_alter_on_schedule_completion opt_ev_rename_to opt_ev_sql_stmt
        trg_action_time trg_event
        view_check_option
        signed_num
        opt_ignore_unknown_user
        opt_histogram_num_buckets


%type <order_direction>
        ordering_direction opt_ordering_direction


%type <num> opt_start_transaction_option_list
%type <num> start_transaction_option_list
%type <num> start_transaction_option

%type <m_yes_no_unk>
        opt_chain opt_release

%type <m_fk_option>
        delete_option

%type <ulong_num>
        ulong_num real_ulong_num merge_insert_types
        ws_num_codepoints func_datetime_precision
        now
        opt_checksum_type
        opt_ignore_lines
        opt_profile_defs
        profile_defs
        profile_def
        factor
        opt_source_count
        opt_load_parallel

%type <ulonglong_number>
        ulonglong_num real_ulonglong_num size_number
        option_autoextend_size opt_load_memory

%type <lock_type>
        replace_lock_option opt_low_priority insert_lock_option load_data_lock

%type <locked_row_action> locked_row_action opt_locked_row_action

%type <item>
        literal insert_column temporal_literal
        simple_ident expr opt_expr opt_else
        set_function_specification sum_expr
        in_sum_expr grouping_operation
        window_func_call opt_ll_default
        bool_pri
        predicate bit_expr
        table_wild simple_expr udf_expr
        expr_or_default set_expr_or_default
        geometry_function
        signed_literal now_or_signed_literal
        simple_ident_nospvar simple_ident_q
        field_or_var limit_option
        function_call_keyword
        function_call_nonkeyword
        function_call_generic
        function_call_conflict
        signal_allowed_expr
        simple_target_specification
        condition_number
        filter_db_ident
        filter_table_ident
        filter_string
        select_item
        opt_where_clause
        where_clause
        opt_having_clause
        opt_qualify_clause
        opt_simple_limit
        null_as_literal
        literal_or_null
        signed_literal_or_null
        stable_integer
        param_or_var
        in_expression_user_variable_assignment
        rvalue_system_or_user_variable
        install_set_rvalue
        sampling_percentage

%type <item_string> window_name opt_existing_window_name

%type <item_num> NUM_literal
        int64_literal

%type <item_list>
        when_list
        opt_filter_db_list filter_db_list
        opt_filter_table_list filter_table_list
        opt_filter_string_list filter_string_list
        opt_filter_db_pair_list filter_db_pair_list

%type <item_list2>
        expr_list udf_expr_list opt_udf_expr_list opt_expr_list select_item_list
        opt_paren_expr_list ident_list_arg ident_list values opt_values row_value
        insert_columns
        fields_or_vars
        opt_field_or_var_spec
        row_value_explicit

%type <var_type>
        option_type opt_var_type opt_rvalue_system_variable_type
        opt_set_var_ident_type install_option_type

%type <key_type>
        opt_unique constraint_key_type

%type <key_alg>
        index_type

%type <string_list>
        string_list using_list opt_use_partition use_partition ident_string_list
        all_or_alt_part_name_list

%type <key_part>
        key_part key_part_with_expression

%type <date_time_type> date_time_type;
%type <interval> interval

%type <interval_time_st> interval_time_stamp

%type <row_type> row_types

%type <resource_group_type> resource_group_types

%type <resource_group_vcpu_list_type>
        opt_resource_group_vcpu_list
        vcpu_range_spec_list

%type <resource_group_priority_type> opt_resource_group_priority

%type <resource_group_state_type> opt_resource_group_enable_disable

%type <resource_group_flag_type> opt_force

%type <thread_id_list_type> thread_id_list thread_id_list_options

%type <vcpu_range_type> vcpu_num_or_range

%type <tx_isolation> isolation_types

%type <ha_rkey_mode> handler_rkey_mode

%type <ha_read_mode> handler_scan_function
        handler_rkey_function

%type <cast_type> cast_type opt_returning_type

%type <lexer.keyword> ident_keyword label_keyword role_keyword
        lvalue_keyword
        ident_keywords_unambiguous
        ident_keywords_ambiguous_1_roles_and_labels
        ident_keywords_ambiguous_2_labels
        ident_keywords_ambiguous_3_roles
        ident_keywords_ambiguous_4_system_variables

%type <lex_user> user_ident_or_text user create_user alter_user user_func role

%type <lex_mfa>
        identification
        identified_by_password
        identified_by_random_password
        identified_with_plugin
        identified_with_plugin_as_auth
        identified_with_plugin_by_random_password
        identified_with_plugin_by_password
        opt_initial_auth
        opt_user_registration

%type <lex_mfas> opt_create_user_with_mfa

%type <lexer.charset>
        opt_collate
        charset_name
        old_or_new_charset_name
        old_or_new_charset_name_or_default
        collation_name
        opt_load_data_charset
        UNDERSCORE_CHARSET
        ascii unicode
        default_charset default_collation

%type <boolfunc2creator> comp_op

%type <num>  sp_decl_idents sp_opt_inout sp_handler_type sp_hcond_list
%type <spcondvalue> sp_cond sp_hcond sqlstate signal_value opt_signal_value
%type <spblock> sp_decls sp_decl
%type <spname> sp_name
%type <index_hint> index_hint_type
%type <num> index_hint_clause
%type <filetype> data_or_xml
%type <source_type> load_source_type

%type <da_condition_item_name> signal_condition_information_item_name

%type <diag_area> which_area;
%type <diag_info> diagnostics_information;
%type <stmt_info_item> statement_information_item;
%type <stmt_info_item_name> statement_information_item_name;
%type <stmt_info_list> statement_information;
%type <cond_info_item> condition_information_item;
%type <cond_info_item_name> condition_information_item_name;
%type <cond_info_list> condition_information;
%type <signal_item_list> signal_information_item_list;
%type <signal_item_list> opt_set_signal_information;

%type <trg_characteristics> trigger_follows_precedes_clause;
%type <trigger_action_order_type> trigger_action_order;

%type <xid> xid;
%type <xa_option_type> opt_join_or_resume;
%type <xa_option_type> opt_suspend;
%type <xa_option_type> opt_one_phase;

%type <is_not_empty> opt_convert_xid opt_ignore opt_linear opt_bin_mod
        opt_if_not_exists opt_temporary
        opt_grant_option opt_with_admin_option
        opt_full opt_extended
        opt_ignore_leaves
        opt_local
        opt_retain_current_password
        opt_discard_old_password
        opt_constraint_enforcement
        constraint_enforcement
        opt_not
        opt_interval
        opt_source_order
        opt_load_algorithm
        opt_histogram_auto_update

%type <show_cmd_type> opt_show_cmd_type


%type <num> opt_replica_thread_option_list
%type <num> replica_thread_option_list
%type <num> replica_thread_option

%type <key_usage_element> key_usage_element

%type <key_usage_list> key_usage_list opt_key_usage_list index_hint_definition
        index_hints_list opt_index_hints_list opt_key_definition
        opt_cache_key_list

%type <order_expr> order_expr alter_order_item
        grouping_expr

%type <order_list> order_list group_list gorder_list opt_gorder_clause
      alter_order_list opt_partition_clause opt_window_order_by_clause

%type<tablesample> opt_tablesample_clause

%type <c_str> field_length opt_field_length type_datetime_precision
        opt_place

%type <precision> precision opt_precision float_options standard_float_options

%type <charset_with_opt_binary> opt_charset_with_opt_binary

%type <limit_options> limit_options

%type <limit_clause> limit_clause opt_limit_clause

%type <ulonglong_number> query_spec_option

%type <select_options> select_option select_option_list select_options

%type <node>
          option_value

%type <join_table> joined_table joined_table_parens

%type <table_reference_list> opt_from_clause from_clause from_tables
        table_reference_list table_reference_list_parens explicit_table

%type <olap_type> olap_opt
%type <tablesample_type> sampling_method

%type <group> opt_group_clause

%type <windows> opt_window_clause  
                                   
                window_definition_list

%type <window> window_definition window_spec window_spec_details window_name_or_spec
  windowing_clause   
  opt_windowing_clause 
                       

%type <window_frame> opt_window_frame_clause

%type <frame_units> window_frame_units

%type <frame_extent> window_frame_extent window_frame_between

%type <bound> window_frame_start window_frame_bound

%type <frame_exclusion> opt_window_frame_exclusion

%type <null_treatment> opt_null_treatment

%type <lead_lag_info> opt_lead_lag_info

%type <from_first_last> opt_from_first_last

%type <order> order_clause opt_order_clause

%type <locking_clause> locking_clause

%type <locking_clause_list> locking_clause_list

%type <lock_strength> lock_strength

%type <table_reference> table_reference esc_table_reference
        table_factor single_table single_table_parens table_function

%type <bipartite_name> lvalue_variable rvalue_system_variable

%type <option_value_following_option_type> option_value_following_option_type

%type <option_value_no_option_type> option_value_no_option_type

%type <option_value_list> option_value_list option_value_list_continued

%type <start_option_value_list> start_option_value_list

%type <transaction_access_mode> transaction_access_mode
        opt_transaction_access_mode

%type <isolation_level> isolation_level opt_isolation_level

%type <transaction_characteristics> transaction_characteristics

%type <start_option_value_list_following_option_type>
        start_option_value_list_following_option_type

%type <set> set

%type <line_separators> line_term line_term_list opt_line_term

%type <field_separators> field_term field_term_list opt_field_term

%type <into_destination> into_destination into_clause

%type <select_var_ident> select_var_ident

%type <select_var_list> select_var_list

%type <query_expression_body_opt_parens> query_expression_body

%type <query_expression_body>
        as_create_query_expression
        query_expression_parens
        query_expression_with_opt_locking_clauses

%type <query_primary>
        query_primary
        query_specification

%type <query_expression> query_expression

%type <subquery> subquery row_subquery table_subquery

%type <derived_table> derived_table

%type <param_marker> param_marker

%type <text_literal> text_literal

%type <top_level_node>
        alter_instance_stmt
        alter_resource_group_stmt
        alter_table_stmt
        analyze_table_stmt
        call_stmt
        check_table_stmt
        create_index_stmt
        create_resource_group_stmt
        create_role_stmt
        create_srs_stmt
        create_table_stmt
        delete_stmt
        describe_stmt
        do_stmt
        drop_index_stmt
        drop_resource_group_stmt
        drop_role_stmt
        drop_srs_stmt
        explain_stmt
        handler_stmt
        insert_stmt
        keycache_stmt
        load_stmt
        optimize_table_stmt
        preload_stmt
        repair_table_stmt
        replace_stmt
        restart_server_stmt
        select_stmt
        select_stmt_with_into
        set_resource_group_stmt
        set_role_stmt
        show_binary_log_status_stmt
        show_binary_logs_stmt
        show_binlog_events_stmt
        show_character_set_stmt
        show_collation_stmt
        show_columns_stmt
        show_count_errors_stmt
        show_count_warnings_stmt
        show_create_database_stmt
        show_create_event_stmt
        show_create_function_stmt
        show_create_procedure_stmt
        show_create_table_stmt
        show_create_trigger_stmt
        show_create_user_stmt
        show_create_view_stmt
        show_databases_stmt
        show_engine_logs_stmt
        show_engine_mutex_stmt
        show_engine_status_stmt
        show_engines_stmt
        show_errors_stmt
        show_events_stmt
        show_function_code_stmt
        show_function_status_stmt
        show_grants_stmt
        show_keys_stmt
        show_open_tables_stmt
        show_parse_tree_stmt
        show_plugins_stmt
        show_privileges_stmt
        show_procedure_code_stmt
        show_procedure_status_stmt
        show_processlist_stmt
        show_profile_stmt
        show_profiles_stmt
        show_relaylog_events_stmt
        show_replica_status_stmt
        show_replicas_stmt
        show_status_stmt
        show_table_status_stmt
        show_tables_stmt
        show_triggers_stmt
        show_variables_stmt
        show_warnings_stmt
        shutdown_stmt
        simple_statement
        truncate_stmt
        update_stmt
        install_stmt

%type <table_ident> table_ident_opt_wild

%type <table_ident_list> table_alias_ref_list table_locking_list

%type <simple_ident_list> simple_ident_list opt_derived_column_list

%type <num> opt_delete_options

%type <opt_delete_option> opt_delete_option

%type <column_value_pair>
        update_elem

%type <column_value_list_pair>
        update_list
        opt_insert_update_list

%type <values_list> values_list insert_values table_value_constructor
        values_row_list

%type <insert_query_expression> insert_query_expression

%type <column_row_value_list_pair> insert_from_constructor

%type <lexer.optimizer_hints> SELECT_SYM INSERT_SYM REPLACE_SYM UPDATE_SYM DELETE_SYM

%type <join_type> outer_join_type natural_join_type inner_join_type

%type <user_list> user_list role_list default_role_clause opt_except_role_list

%type <alter_instance_cmd> alter_instance_action

%type <index_column_list> key_list key_list_with_expression

%type <index_options> opt_index_options index_options  opt_fulltext_index_options
          fulltext_index_options opt_spatial_index_options spatial_index_options

%type <opt_index_lock_and_algorithm> opt_index_lock_and_algorithm

%type <index_option> index_option common_index_option fulltext_index_option
          spatial_index_option
          index_type_clause
          opt_index_type_clause

%type <alter_table_algorithm> alter_algorithm_option_value
        alter_algorithm_option

%type <alter_table_lock> alter_lock_option_value alter_lock_option

%type <table_constraint_def> table_constraint_def

%type <index_name_and_type> opt_index_name_and_type

%type <visibility> visibility

%type <with_clause> with_clause opt_with_clause
%type <with_list> with_list
%type <common_table_expr> common_table_expr

%type <partition_option> part_option

%type <partition_option_list> opt_part_options part_option_list

%type <sub_part_definition> sub_part_definition

%type <sub_part_list> sub_part_list opt_sub_partition

%type <part_value_item> part_value_item

%type <part_value_item_list> part_value_item_list

%type <part_value_item_list_paren> part_value_item_list_paren part_func_max

%type <part_value_list> part_value_list

%type <part_values> part_values_in

%type <opt_part_values> opt_part_values

%type <part_definition> part_definition

%type <part_def_list> part_def_list opt_part_defs

%type <ulong_num> opt_num_subparts opt_num_parts

%type <name_list> name_list opt_name_list

%type <opt_key_algo> opt_key_algo

%type <opt_sub_part> opt_sub_part

%type <part_type_def> part_type_def

%type <partition_clause> partition_clause

%type <mi_type> mi_repair_type mi_repair_types opt_mi_repair_types
        mi_check_type mi_check_types opt_mi_check_types

%type <opt_restrict> opt_restrict;

%type <table_list> table_list opt_table_list

%type <ternary_option> ternary_option;

%type <create_table_option> create_table_option

%type <create_table_options> create_table_options

%type <space_separated_alter_table_opts> create_table_options_space_separated

%type <on_duplicate> duplicate opt_duplicate

%type <col_attr> column_attribute

%type <column_format> column_format

%type <storage_media> storage_media

%type <col_attr_list> column_attribute_list opt_column_attribute_list

%type <virtual_or_stored> opt_stored_attribute

%type <field_option> field_option field_opt_list field_options

%type <int_type> int_type

%type <type> spatial_type type

%type <numeric_type> real_type numeric_type

%type <sp_default> sp_opt_default

%type <field_def> field_def

%type <item> check_constraint

%type <table_constraint_def> opt_references

%type <fk_options> opt_on_update_delete

%type <opt_match_clause> opt_match_clause

%type <reference_list> reference_list opt_ref_list

%type <fk_references> references

%type <column_def> column_def

%type <table_element> table_element

%type <table_element_list> table_element_list

%type <create_table_tail> opt_create_table_options_etc
        opt_create_partitioning_etc opt_duplicate_as_qe

%type <wild_or_where> opt_wild_or_where


%type <jtc_list> columns_clause columns_list
%type <jt_column> jt_column
%type <json_on_response> json_on_response on_empty on_error
%type <json_on_error_or_empty> opt_on_empty_or_error
        opt_on_empty_or_error_json_table
%type <jt_column_type> jt_column_type

%type <acl_type> opt_acl_type
%type <histogram_param> opt_histogram_update_param
%type <histogram> opt_histogram

%type <lex_cstring_list> column_list opt_column_list

%type <role_or_privilege> role_or_privilege

%type <role_or_privilege_list> role_or_privilege_list

%type <with_validation> with_validation opt_with_validation


%type <alter_table_action> alter_list_item alter_table_partition_options
%type <ts_options> logfile_group_option_list opt_logfile_group_options
                   alter_logfile_group_option_list opt_alter_logfile_group_options
                   tablespace_option_list opt_tablespace_options
                   alter_tablespace_option_list opt_alter_tablespace_options
                   opt_drop_ts_options drop_ts_option_list
                   undo_tablespace_option_list opt_undo_tablespace_options

%type <alter_table_standalone_action> standalone_alter_commands

%type <algo_and_lock_and_validation>alter_commands_modifier
        alter_commands_modifier_list

%type <alter_list> alter_list opt_alter_command_list opt_alter_table_actions

%type <standalone_alter_table_action> standalone_alter_table_action

%type <assign_to_keycache> assign_to_keycache

%type <keycache_list> keycache_list

%type <adm_partition> adm_partition

%type <preload_keys> preload_keys

%type <preload_list> preload_list
%type <ts_option>
        alter_logfile_group_option
        alter_tablespace_option
        drop_ts_option
        logfile_group_option
        tablespace_option
        undo_tablespace_option
        ts_option_autoextend_size
        ts_option_comment
        ts_option_engine
        ts_option_extent_size
        ts_option_file_block_size
        ts_option_initial_size
        ts_option_max_size
        ts_option_nodegroup
        ts_option_redo_buffer_size
        ts_option_undo_buffer_size
        ts_option_wait
        ts_option_encryption
        ts_option_engine_attribute

%type <explain_options_type> opt_explain_format
%type <explain_options_type> opt_explain_options

%type <explainable_stmt> explainable_stmt

%type <load_set_element> load_data_set_elem

%type <load_set_list> load_data_set_list opt_load_data_set_spec

%type <install_component_set_list> install_set_value_list opt_install_set_value_list
%type <install_component_set_element>  install_set_value

%type <num> opt_array_cast
%type <sql_cmd_srs_attributes> srs_attributes

%type <insert_update_values_reference> opt_values_reference

%type <alter_tablespace_type> undo_tablespace_state

%type <query_id> opt_for_query


%skeleton "gaur_mysql.c" 

%code{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct node_t node_t;

/**
 * struct node_t - A node of our semantic tree
 * @n_children: Number of children nodes.
 * @yykind: Kind of the node (given by flex / bison).
 * @rule_id: Rule id of node (given by bison), -1 if node is a terminal.
 * @rule_random: Random tag associated with the node.
 * @rule_order: Order of appearance of the node when parsing.
 * @sem_val: Semantic value associated with the node, NULL if none.
 * @first_child: Pointer to the first child node.
 * @next_brother: Pointer to the next sibling node.
 */
struct node_t
{
    int n_children;
    int yykind;
    int rule_id;
    int rule_random;
    int rule_order;
    char *sem_val;
    struct node_t *first_child;
    struct node_t *next_brother;
};

#define GAUR_TAB_MAX_L 10000

/**
 *  Tab servers as a stack of pt nodes until they are given a father
 * - Each shift increments the number of element in the array
 * - Each reduce reduce the number of elements by the number of rhs elements (direct childrens)
 */
node_t *tab[GAUR_TAB_MAX_L];

/**
 * index_tab stores the index of the next available position in the tab
 *  index_tab - 1 corresponds to the index of the last shifted element (when index_tab > 0s)
 */
int index_tab = 0;
int is_collector_error = 0;
int rule_counter = 0;

#define GAUR_PARSE_BEGIN(size, thd) \
    int n_terminal = 0;             \
    int n_nonterminal = 0;          \
    uint64_t ggid = thd->query_id;  \
    index_tab = 0;                  \
    rule_counter = 0;               \
    is_collector_error = 0;

#define GET_RANDOM_TAG(i) (ggrulesem[i - 2])

#define GAUR_ERROR()                                           \
    do                                                         \
    {                                                          \
        collect_and_clean(ggid, n_terminal, n_nonterminal, 1); \
    } while (0);

#define GAUR_SHIFT(yytoken, yytokenvalue)                          \
    do                                                             \
    {                                                              \
        if (yytoken == YYSYMBOL_YYEOF)                             \
            collect_and_clean(ggid, n_terminal, n_nonterminal, 0); \
        else                                                       \
        {                                                          \
            shift(yytoken, yytokenvalue, ggid);                    \
            n_terminal++;                                          \
        }                                                          \
    } while (0);

#define GAUR_REDUCE(nrule, yylen, yykind)                                  \
    do                                                                     \
    { /* We substract 1 to nrule because of the bison accept rule offset*/ \
        n_nonterminal++;                                                   \
        reduce(yylen, nrule - 1, GET_RANDOM_TAG(nrule), yykind);             \
    } while (0)

    static struct
    {
        int value;
        const char *name;
    } _random_mapping[] = {
        {1 << 0, "random1"},
        {1 << 1, "random2"},
        {1 << 2, "random3"},
        {1 << 3, "random4"},
        {1 << 4, "random5"},
        {1 << 5, "random6"},
        {1 << 6, "random7"},
        {1 << 7, "random8"},
        {1 << 8, "random9"},
        {1 << 9, "random10"},
        {1 << 10, "random11"},
        {1 << 11, "random12"},
        {1 << 12, "random13"},
        {1 << 13, "random14"},
        {1 << 14, "random15"},
        {1 << 15, "random16"},
        {1 << 16, "random17"},
        {1 << 17, "random18"},
        {1 << 18, "random19"},
        {1 << 19, "random20"},
        {1 << 20, "random21"},
        {1 << 21, "random22"},
        {1 << 22, "random23"},
        {1 << 23, "random24"},
        {1 << 24, "random25"},
        {1 << 25, "random26"},
        {1 << 26, "random27"},
        {1 << 27, "random28"},
        {1 << 28, "random29"},
        {1 << 29, "random30"},
    };

/**
 * @brief Called when a shift occurs, we create a node_t object and store it in the tab
 *
 * @param yykind Kind of shifted item (given by flex / bison).
 * @param yyvaluep Pointer to the item semantic value
 * @param ggid Identifier generated by MySQL
 */
void shift(int yykind, YYSTYPE const *const yyvaluep, int ggid)
{
    if (index_tab >= GAUR_TAB_MAX_L || is_collector_error)
    {
        fprintf(stderr, "gaur data collector - shift(): incorrect index_tab: %d for query %d\n", index_tab, ggid);
        is_collector_error = 1;
        return;
    }
    tab[index_tab] = (struct node_t *)malloc(sizeof(struct node_t));
    tab[index_tab]->n_children = 0;
    tab[index_tab]->first_child = NULL;
    tab[index_tab]->next_brother = NULL;
    tab[index_tab]->rule_random = 0;
    tab[index_tab]->yykind = yykind;
    tab[index_tab]->rule_id = -1;
    tab[index_tab]->rule_order = rule_counter++;

    switch (yykind)
    {
    case YYSYMBOL_TEXT_STRING:
    case YYSYMBOL_IDENT_QUOTED:
    case YYSYMBOL_DECIMAL_NUM:
    case YYSYMBOL_FLOAT_NUM:
    case YYSYMBOL_NUM:
    case YYSYMBOL_LONG_NUM:
    case YYSYMBOL_HEX_NUM:
    case YYSYMBOL_LEX_HOSTNAME:
    case YYSYMBOL_ULONGLONG_NUM:
    case YYSYMBOL_DOLLAR_QUOTED_STRING_SYM:
    case YYSYMBOL_NCHAR_STRING:
    case YYSYMBOL_BIN_NUM:
    {
        tab[index_tab]->sem_val = strdup(yyvaluep->lexer.lex_str.str);
        break;
    }

    // case YYSYMBOL_ident_or_text: -> is a nterm
    // case YYSYMBOL_IDENT_sys: -> is a nterm
    // case YYSYMBOL_TEXT_STRING_sys:-> is a nterm
    // case YYSYMBOL_TEXT_STRING_literal:-> is a nterm
    // case YYSYMBOL_TEXT_STRING_filesystem:-> is a nterm
    // case YYSYMBOL_TEXT_STRING_sys_nonewline: -> is a nterm
    // case YYSYMBOL_TEXT_STRING_password: -> is a nterm
    // case YYSYMBOL_TEXT_STRING_hash:-> is a nterm
    // case YYSYMBOL_TEXT_STRING_validated:-> is a nterm
    default:
    {
        tab[index_tab]->sem_val = NULL;
        break;
    }
    }
    index_tab++;
}

/**
 * @brief Called when a parser reduction occurs, we create a father node_t object, associate it with its children, remove them from tab and store the father in tab.
 *
 * @param n_children Number of rule rhs (number of children to retrieve in tab)
 * @param r_id Rule id (given by bison)
 * @param r_random Rule random tag
 * @param yykind Kind of the node (given by flex / bison)
 */
void reduce(int n_children, int r_id, int r_random, int yykind)
{
    if (is_collector_error) /* Skip reduction if tree is already messed up */
        return;

    node_t *father_node = (struct node_t *)malloc(sizeof(struct node_t));
    father_node->rule_id = r_id;
    father_node->rule_random = r_random;
    father_node->rule_order = rule_counter++;
    father_node->n_children = n_children;
    father_node->yykind = yykind;
    father_node->sem_val = NULL;

    if (n_children > 0)
    {
        /* We have at least a child: retrieve first node child (tab[index_tab - 1]) */
        index_tab--;
        int remaining_children = n_children - 1; // Store number of remaining children to associate to father.
        father_node->first_child = tab[index_tab];

        node_t *last_children = father_node->first_child; // Store children on which to append next brother

        /* collect n_children last values of array tab and associate them to their father */
        for (int i = 0; i < remaining_children; i++)
        {
            index_tab--;
            if (index_tab < 0 || index_tab >= GAUR_TAB_MAX_L)
            {
                fprintf(stderr, "gaur data collector - reduce(): incorrect index_tab: %d\n", index_tab);

                is_collector_error = 1;
                return;
            }
            last_children->next_brother = tab[index_tab];
            last_children = last_children->next_brother;
        }
    }

    tab[index_tab] = father_node;
    index_tab++;
}

/**
 * @brief Check existence of file, if not exists create it, and create header line, then return file pointer.
 * If already exists, just return file pointer.
 *
 * @return FILE*
 */
FILE *gaur_open_file()
{
    const char *output_name = "gaur.log";
    FILE *f_logs = fopen(output_name, "r");
    if (f_logs == NULL)
    {
        f_logs = fopen(output_name, "w");
        if (f_logs != NULL)
        {
            fprintf(f_logs, "query_id,n_terminal,n_nonterminal,is_syntax_error,semantic_tree,depth\n");
        }
    }
    else
    {
        fclose(f_logs);
        f_logs = fopen(output_name, "a");
    }

    return f_logs;
}

/**
 * @brief Compute the depth of a tree starting from a given node.
 *
 *  Should only be called if input is syntactically valid: the tree is complete
 * @param tree_root
 * @return int Depth of tree.
 */
int get_tree_depth(node_t *tree_root)
{
    if (tree_root == NULL)
        return 0;

    int max = 0;
    int current;

    node_t *next_child = tree_root->first_child;

    for (int i = 0; i < tree_root->n_children; i++)
    {
        current = get_tree_depth(next_child);

        if (current > max)
            max = current;

        next_child = next_child->next_brother;
    }
    return max + 1;
}

/**
 * @brief Function to print additionnal tree features:
 * Depth of the tree
 * @param f
 */
void print_tree_features(FILE *f)
{
    int depth_tree = get_tree_depth(tab[index_tab - 1]);
    fprintf(f, ",%d", depth_tree);
}

/**
 * @brief Print in given file the edges between nodes in the given tree.
 *
 * Each root node edges relations are represented with the following
 * custom format: X>Y:Y':Y''...:  where X is the root node rule order, and Y, Y', Y''...
 * are the rule order of the children of the root node.
 *
 * @param root_node First node of the tree
 * @param f File to output to
 */
void print_edges_relation(node_t *root_node, FILE *f)
{
    /* If root node is null or no children we return */
    if (root_node == NULL || root_node->n_children == 0)
        return;

    fprintf(f, " %d>", root_node->rule_order);
    node_t *current_node = root_node->first_child;
    /* Print edges between root_node and its children. */
    for (int i = 0; i < root_node->n_children; i++)
    {
        fprintf(f, "%d:", current_node->rule_order);
        current_node = current_node->next_brother;
    }
    /* Now iterate over children to display their edges */
    current_node = root_node->first_child;
    for (int i = 0; i < root_node->n_children; i++)
    {
        print_edges_relation(current_node, f);
        current_node = current_node->next_brother;
    }
}

/**
 * @brief Function that makes sure printing the sem_value does not mess with our logfile format
 * - We enclosed the whole semantic tree in double quotes: every occurence of double quotes must be doubled within the string
 * - We also need to make sure no ":" is present, For now we replace them by GAUR_SEMICOLON which is replaced back when post-processing the log file until we find a cleaner way
 * - We also need to make sure no "|" is present
 * @param sem_val
 * @param f
 */
void safe_sem_value_print(char *sem_val, FILE *f)
{
    if (sem_val != NULL)
    {
        for (size_t i = 0; i < strlen(sem_val); i++)
        {
            if (sem_val[i] == '"')
                fprintf(f, "\"\"");
            else if (sem_val[i] == '|')
                fprintf(f, "G_PIPE");
            else if (sem_val[i] == ':')
                fprintf(f, "G_SEMICOLON");
            else
                fprintf(f, "%c", sem_val[i]);
        }
    }
}

/**
 * @brief Print nodes, and their attributes
 *  | appearance_int:symbol_kind:rule_id:random::sem_value
 * @param root_node
 * @param f
 */
void print_nodes_attr(node_t *root_node, FILE *f)
{
    // TODO: append all text to a buffer and only print once
    if (root_node == NULL)
        return;

    fprintf(f, "|%d:%d:%d:", root_node->rule_order, root_node->yykind, root_node->rule_id);

    /* Now print randomly assigned tag */
    for (size_t i = 0; i < sizeof(_random_mapping) / sizeof(_random_mapping[0]); i++)
    {
        if (root_node->rule_random & _random_mapping[i].value)
        {
            fprintf(f, "%s", _random_mapping[i].name);
            break;
        }
    }
    fprintf(f, "::");
    // I let the same number of attributes, it'll make preprocessing easier.
    if (root_node->sem_val != NULL)
    {
        safe_sem_value_print(root_node->sem_val, f);
    }

    node_t *current_node = root_node->first_child;
    for (int i = 0; i < root_node->n_children; i++)
    {
        print_nodes_attr(current_node, f);
        current_node = current_node->next_brother;
    }
}

/**
 * @brief Free the memory allocated for a node and its children
 *
 * @param node Tree node to free
 */
void free_node_and_child(node_t *node)
{
    if (node == NULL)
        return;

    node_t *current_node = node->first_child;
    for (int i = 0; i < node->n_children; i++)
    {
        node_t *next = current_node->next_brother;
        free_node_and_child(current_node);
        current_node = next;
    }

    if (node->sem_val != NULL)
    {
        free(node->sem_val);
    }

    free(node);
}

/**
 * @brief Wrapper for nodes and edges printing
 *
 * @param f
 */
void print_tree_MY(FILE *f)
{
    fprintf(f, ",\"");
    print_nodes_attr(tab[index_tab - 1], f);
    fprintf(f, "||-||"); /* Allows to separate node declaration from edges*/
    print_edges_relation(tab[index_tab - 1], f);
    fprintf(f, "\"");
}

/**
 * @brief Create the log entry corresponding to parsed input and clean the semantic tree data structure
 *
 * @param query_id id to identify query, generated by MySQL
 * @param n_terminal number of terminal nodes in semantic tree
 * @param n_nonterminal number of non-terminal nodes in semantic tree
 * @param is_error presence of syntax error
 */
void collect_and_clean(uint64_t query_id, int n_terminal, int n_nonterminal, int is_error)
{
    FILE *f_logs = gaur_open_file();
    if (f_logs != NULL)
    {
        fprintf(f_logs, "%" PRId64 ",", query_id); /* Print Input ID*/
        fprintf(f_logs, "%d,%d,%d", n_terminal, n_nonterminal, is_error);

        if (is_collector_error)
            fprintf(f_logs, ",,\n"); // One for pt, one for depth
        else
        {
            print_tree_MY(f_logs);
            print_tree_features(f_logs);
            fprintf(f_logs, "\n");
        }
        fclose(f_logs);
    }
    else
    {
        perror("Gaur: Could not open log file.");
    }

    for (int i = 1; i <= index_tab; i++)
    {
        free_node_and_child(tab[index_tab - i]);
        tab[index_tab - i] = NULL;
    }
}

	static const  int32_t ggrulesem[3192] = {
		0b000000000000000100000, /* Rule number: 001 start_entry.0 */
		0b000010000000000000000, /* Rule number: 002 start_entry.1 */
		0b000100000000000000000, /* Rule number: 003 start_entry.2 */
		0b000000000000000000010, /* Rule number: 004 start_entry.3 */
		0b000000010000000000000, /* Rule number: 005 start_entry.4 */
		0b000000000000001000000, /* Rule number: 006 start_entry.5 */
		0b000000001000000000000, /* Rule number: 007 $@1 */
		0b000000000000001000000, /* Rule number: 008 sql_statement.0 */
		0b000000000010000000000, /* Rule number: 009 sql_statement.1 */
		0b000000001000000000000, /* Rule number: 010 sql_statement.2 */
		0b000000010000000000000, /* Rule number: 011 opt_end_of_input.0 */
		0b000000100000000000000, /* Rule number: 012 opt_end_of_input.1 */
		0b000010000000000000000, /* Rule number: 013 simple_statement_or_begin.0 */
		0b000000000000000010000, /* Rule number: 014 simple_statement_or_begin.1 */
		0b000000010000000000000, /* Rule number: 015 simple_statement.0 */
		0b000000000000100000000, /* Rule number: 016 simple_statement.1 */
		0b100000000000000000000, /* Rule number: 017 simple_statement.2 */
		0b000000000001000000000, /* Rule number: 018 simple_statement.3 */
		0b000000100000000000000, /* Rule number: 019 simple_statement.4 */
		0b000000000000000000010, /* Rule number: 020 simple_statement.5 */
		0b000000000000100000000, /* Rule number: 021 simple_statement.6 */
		0b000001000000000000000, /* Rule number: 022 simple_statement.7 */
		0b000000000000000010000, /* Rule number: 023 simple_statement.8 */
		0b100000000000000000000, /* Rule number: 024 simple_statement.9 */
		0b001000000000000000000, /* Rule number: 025 simple_statement.10 */
		0b000000000100000000000, /* Rule number: 026 simple_statement.11 */
		0b000000000000001000000, /* Rule number: 027 simple_statement.12 */
		0b000000100000000000000, /* Rule number: 028 simple_statement.13 */
		0b000010000000000000000, /* Rule number: 029 simple_statement.14 */
		0b000000000000001000000, /* Rule number: 030 simple_statement.15 */
		0b000000000100000000000, /* Rule number: 031 simple_statement.16 */
		0b000100000000000000000, /* Rule number: 032 simple_statement.17 */
		0b000100000000000000000, /* Rule number: 033 simple_statement.18 */
		0b000000001000000000000, /* Rule number: 034 simple_statement.19 */
		0b000000000000000000010, /* Rule number: 035 simple_statement.20 */
		0b000000000000000010000, /* Rule number: 036 simple_statement.21 */
		0b010000000000000000000, /* Rule number: 037 simple_statement.22 */
		0b100000000000000000000, /* Rule number: 038 simple_statement.23 */
		0b000000000000000010000, /* Rule number: 039 simple_statement.24 */
		0b000000000000100000000, /* Rule number: 040 simple_statement.25 */
		0b000000010000000000000, /* Rule number: 041 simple_statement.26 */
		0b000000000010000000000, /* Rule number: 042 simple_statement.27 */
		0b000000000100000000000, /* Rule number: 043 simple_statement.28 */
		0b000100000000000000000, /* Rule number: 044 simple_statement.29 */
		0b100000000000000000000, /* Rule number: 045 simple_statement.30 */
		0b000000010000000000000, /* Rule number: 046 simple_statement.31 */
		0b100000000000000000000, /* Rule number: 047 simple_statement.32 */
		0b000010000000000000000, /* Rule number: 048 simple_statement.33 */
		0b000100000000000000000, /* Rule number: 049 simple_statement.34 */
		0b010000000000000000000, /* Rule number: 050 simple_statement.35 */
		0b000100000000000000000, /* Rule number: 051 simple_statement.36 */
		0b010000000000000000000, /* Rule number: 052 simple_statement.37 */
		0b000000000000000000010, /* Rule number: 053 simple_statement.38 */
		0b000010000000000000000, /* Rule number: 054 simple_statement.39 */
		0b000000000000000000010, /* Rule number: 055 simple_statement.40 */
		0b010000000000000000000, /* Rule number: 056 simple_statement.41 */
		0b000001000000000000000, /* Rule number: 057 simple_statement.42 */
		0b000000000100000000000, /* Rule number: 058 simple_statement.43 */
		0b000000000000000001000, /* Rule number: 059 simple_statement.44 */
		0b001000000000000000000, /* Rule number: 060 simple_statement.45 */
		0b000000000000000000010, /* Rule number: 061 simple_statement.46 */
		0b000000000000000000100, /* Rule number: 062 simple_statement.47 */
		0b000000000000000000100, /* Rule number: 063 simple_statement.48 */
		0b000100000000000000000, /* Rule number: 064 simple_statement.49 */
		0b000000000001000000000, /* Rule number: 065 simple_statement.50 */
		0b000000000000000100000, /* Rule number: 066 simple_statement.51 */
		0b000000000000000010000, /* Rule number: 067 simple_statement.52 */
		0b000000000000100000000, /* Rule number: 068 simple_statement.53 */
		0b000000000001000000000, /* Rule number: 069 simple_statement.54 */
		0b000000000100000000000, /* Rule number: 070 simple_statement.55 */
		0b000000000100000000000, /* Rule number: 071 simple_statement.56 */
		0b000000000000100000000, /* Rule number: 072 simple_statement.57 */
		0b000100000000000000000, /* Rule number: 073 simple_statement.58 */
		0b000000000000001000000, /* Rule number: 074 simple_statement.59 */
		0b000000000000001000000, /* Rule number: 075 simple_statement.60 */
		0b000000000000000000001, /* Rule number: 076 simple_statement.61 */
		0b000000000000000100000, /* Rule number: 077 simple_statement.62 */
		0b000100000000000000000, /* Rule number: 078 simple_statement.63 */
		0b000000000000000010000, /* Rule number: 079 simple_statement.64 */
		0b000010000000000000000, /* Rule number: 080 simple_statement.65 */
		0b000000000001000000000, /* Rule number: 081 simple_statement.66 */
		0b000000001000000000000, /* Rule number: 082 simple_statement.67 */
		0b000000000001000000000, /* Rule number: 083 simple_statement.68 */
		0b000000000000000100000, /* Rule number: 084 simple_statement.69 */
		0b000000000000010000000, /* Rule number: 085 simple_statement.70 */
		0b000000000000000000100, /* Rule number: 086 simple_statement.71 */
		0b000000010000000000000, /* Rule number: 087 simple_statement.72 */
		0b000100000000000000000, /* Rule number: 088 simple_statement.73 */
		0b000000000000100000000, /* Rule number: 089 simple_statement.74 */
		0b000000000000100000000, /* Rule number: 090 simple_statement.75 */
		0b000000000000000100000, /* Rule number: 091 simple_statement.76 */
		0b000000001000000000000, /* Rule number: 092 simple_statement.77 */
		0b000000100000000000000, /* Rule number: 093 simple_statement.78 */
		0b000000100000000000000, /* Rule number: 094 simple_statement.79 */
		0b000000000000100000000, /* Rule number: 095 simple_statement.80 */
		0b000000010000000000000, /* Rule number: 096 simple_statement.81 */
		0b000000000000000001000, /* Rule number: 097 simple_statement.82 */
		0b000000000010000000000, /* Rule number: 098 simple_statement.83 */
		0b000000000000000100000, /* Rule number: 099 simple_statement.84 */
		0b000001000000000000000, /* Rule number: 100 simple_statement.85 */
		0b000010000000000000000, /* Rule number: 101 simple_statement.86 */
		0b000000000000000000001, /* Rule number: 102 simple_statement.87 */
		0b000000000100000000000, /* Rule number: 103 simple_statement.88 */
		0b000000000100000000000, /* Rule number: 104 simple_statement.89 */
		0b100000000000000000000, /* Rule number: 105 simple_statement.90 */
		0b001000000000000000000, /* Rule number: 106 simple_statement.91 */
		0b000000000000100000000, /* Rule number: 107 simple_statement.92 */
		0b000000100000000000000, /* Rule number: 108 simple_statement.93 */
		0b000000001000000000000, /* Rule number: 109 simple_statement.94 */
		0b001000000000000000000, /* Rule number: 110 simple_statement.95 */
		0b000000000010000000000, /* Rule number: 111 simple_statement.96 */
		0b000000000000001000000, /* Rule number: 112 simple_statement.97 */
		0b000000000000000000001, /* Rule number: 113 simple_statement.98 */
		0b000000000000000001000, /* Rule number: 114 simple_statement.99 */
		0b000000100000000000000, /* Rule number: 115 simple_statement.100 */
		0b000000000010000000000, /* Rule number: 116 simple_statement.101 */
		0b000000000000000001000, /* Rule number: 117 simple_statement.102 */
		0b000001000000000000000, /* Rule number: 118 simple_statement.103 */
		0b000000000000000100000, /* Rule number: 119 simple_statement.104 */
		0b000000000000000001000, /* Rule number: 120 simple_statement.105 */
		0b000000000000100000000, /* Rule number: 121 simple_statement.106 */
		0b000000000100000000000, /* Rule number: 122 simple_statement.107 */
		0b000000001000000000000, /* Rule number: 123 simple_statement.108 */
		0b000000000000000100000, /* Rule number: 124 simple_statement.109 */
		0b000001000000000000000, /* Rule number: 125 simple_statement.110 */
		0b000000000100000000000, /* Rule number: 126 simple_statement.111 */
		0b000010000000000000000, /* Rule number: 127 simple_statement.112 */
		0b000000000000100000000, /* Rule number: 128 simple_statement.113 */
		0b000000000100000000000, /* Rule number: 129 simple_statement.114 */
		0b000000000001000000000, /* Rule number: 130 simple_statement.115 */
		0b000000100000000000000, /* Rule number: 131 simple_statement.116 */
		0b010000000000000000000, /* Rule number: 132 simple_statement.117 */
		0b000000000001000000000, /* Rule number: 133 simple_statement.118 */
		0b000000000000000000010, /* Rule number: 134 simple_statement.119 */
		0b000000000000100000000, /* Rule number: 135 simple_statement.120 */
		0b000000000000100000000, /* Rule number: 136 simple_statement.121 */
		0b000000000000010000000, /* Rule number: 137 simple_statement.122 */
		0b000010000000000000000, /* Rule number: 138 simple_statement.123 */
		0b000000010000000000000, /* Rule number: 139 simple_statement.124 */
		0b000000000100000000000, /* Rule number: 140 simple_statement.125 */
		0b000000100000000000000, /* Rule number: 141 simple_statement.126 */
		0b000000000000000100000, /* Rule number: 142 simple_statement.127 */
		0b000000000001000000000, /* Rule number: 143 simple_statement.128 */
		0b000000000000000000100, /* Rule number: 144 simple_statement.129 */
		0b000000000000000010000, /* Rule number: 145 simple_statement.130 */
		0b000001000000000000000, /* Rule number: 146 simple_statement.131 */
		0b000100000000000000000, /* Rule number: 147 simple_statement.132 */
		0b000000000000010000000, /* Rule number: 148 simple_statement.133 */
		0b100000000000000000000, /* Rule number: 149 simple_statement.134 */
		0b010000000000000000000, /* Rule number: 150 simple_statement.135 */
		0b000000000000010000000, /* Rule number: 151 deallocate.0 */
		0b000000001000000000000, /* Rule number: 152 deallocate_or_drop.0 */
		0b000000000000000000001, /* Rule number: 153 deallocate_or_drop.1 */
		0b000000000000001000000, /* Rule number: 154 prepare.0 */
		0b000000000000010000000, /* Rule number: 155 prepare_src.0 */
		0b000000000100000000000, /* Rule number: 156 prepare_src.1 */
		0b000000000010000000000, /* Rule number: 157 $@2 */
		0b100000000000000000000, /* Rule number: 158 execute.0 */
		0b001000000000000000000, /* Rule number: 159 execute_using.0 */
		0b000000000000000010000, /* Rule number: 160 execute_using.1 */
		0b000000100000000000000, /* Rule number: 161 execute_var_list.0 */
		0b000000000000000000100, /* Rule number: 162 execute_var_list.1 */
		0b000000000100000000000, /* Rule number: 163 execute_var_ident.0 */
		0b000000000100000000000, /* Rule number: 164 $@3 */
		0b000000000000010000000, /* Rule number: 165 help.0 */
		0b000000000001000000000, /* Rule number: 166 $@4 */
		0b010000000000000000000, /* Rule number: 167 $@5 */
		0b000000000000001000000, /* Rule number: 168 change_replication_stmt.0 */
		0b000000000000000010000, /* Rule number: 169 change_replication_stmt.1 */
		0b000000000000000010000, /* Rule number: 170 filter_defs.0 */
		0b000000000000000001000, /* Rule number: 171 filter_defs.1 */
		0b000000000000001000000, /* Rule number: 172 filter_def.0 */
		0b010000000000000000000, /* Rule number: 173 filter_def.1 */
		0b000000000000000000010, /* Rule number: 174 filter_def.2 */
		0b000000000000000000100, /* Rule number: 175 filter_def.3 */
		0b100000000000000000000, /* Rule number: 176 filter_def.4 */
		0b000000000000010000000, /* Rule number: 177 filter_def.5 */
		0b000000000010000000000, /* Rule number: 178 filter_def.6 */
		0b000000000000000000001, /* Rule number: 179 opt_filter_db_list.0 */
		0b000000001000000000000, /* Rule number: 180 opt_filter_db_list.1 */
		0b010000000000000000000, /* Rule number: 181 filter_db_list.0 */
		0b000010000000000000000, /* Rule number: 182 filter_db_list.1 */
		0b000000000000100000000, /* Rule number: 183 filter_db_ident.0 */
		0b000000000000000000010, /* Rule number: 184 opt_filter_db_pair_list.0 */
		0b000000000010000000000, /* Rule number: 185 opt_filter_db_pair_list.1 */
		0b000000010000000000000, /* Rule number: 186 filter_db_pair_list.0 */
		0b000000000000000001000, /* Rule number: 187 filter_db_pair_list.1 */
		0b000000000000000100000, /* Rule number: 188 opt_filter_table_list.0 */
		0b100000000000000000000, /* Rule number: 189 opt_filter_table_list.1 */
		0b000000000000000000100, /* Rule number: 190 filter_table_list.0 */
		0b000000010000000000000, /* Rule number: 191 filter_table_list.1 */
		0b000000000000100000000, /* Rule number: 192 filter_table_ident.0 */
		0b000000000000000010000, /* Rule number: 193 opt_filter_string_list.0 */
		0b100000000000000000000, /* Rule number: 194 opt_filter_string_list.1 */
		0b000000000000100000000, /* Rule number: 195 filter_string_list.0 */
		0b000000000100000000000, /* Rule number: 196 filter_string_list.1 */
		0b000000000000001000000, /* Rule number: 197 filter_string.0 */
		0b001000000000000000000, /* Rule number: 198 source_defs.0 */
		0b000000000000000010000, /* Rule number: 199 source_defs.1 */
		0b000000000001000000000, /* Rule number: 200 source_def.0 */
		0b000001000000000000000, /* Rule number: 201 source_def.1 */
		0b000000000000000010000, /* Rule number: 202 source_def.2 */
		0b000000000100000000000, /* Rule number: 203 source_def.3 */
		0b000000000001000000000, /* Rule number: 204 source_def.4 */
		0b000000000010000000000, /* Rule number: 205 source_def.5 */
		0b100000000000000000000, /* Rule number: 206 source_def.6 */
		0b000000001000000000000, /* Rule number: 207 source_def.7 */
		0b000010000000000000000, /* Rule number: 208 source_def.8 */
		0b000001000000000000000, /* Rule number: 209 source_def.9 */
		0b000000000001000000000, /* Rule number: 210 source_def.10 */
		0b000000000000000001000, /* Rule number: 211 source_def.11 */
		0b000000000000001000000, /* Rule number: 212 source_def.12 */
		0b000000000010000000000, /* Rule number: 213 source_def.13 */
		0b000000000000000000001, /* Rule number: 214 source_def.14 */
		0b000000000000000010000, /* Rule number: 215 source_def.15 */
		0b000000010000000000000, /* Rule number: 216 source_def.16 */
		0b000000000000000100000, /* Rule number: 217 source_def.17 */
		0b000000000000000000100, /* Rule number: 218 source_def.18 */
		0b000000000000000010000, /* Rule number: 219 source_def.19 */
		0b000000000000001000000, /* Rule number: 220 source_def.20 */
		0b000000000000000100000, /* Rule number: 221 source_def.21 */
		0b000000000000010000000, /* Rule number: 222 source_def.22 */
		0b000000000000000000010, /* Rule number: 223 source_def.23 */
		0b000000000100000000000, /* Rule number: 224 source_def.24 */
		0b000000000000010000000, /* Rule number: 225 source_def.25 */
		0b000100000000000000000, /* Rule number: 226 source_def.26 */
		0b000000010000000000000, /* Rule number: 227 source_def.27 */
		0b000000000000000001000, /* Rule number: 228 source_def.28 */
		0b000000000010000000000, /* Rule number: 229 source_def.29 */
		0b100000000000000000000, /* Rule number: 230 source_def.30 */
		0b010000000000000000000, /* Rule number: 231 source_def.31 */
		0b000000000001000000000, /* Rule number: 232 source_def.32 */
		0b000010000000000000000, /* Rule number: 233 source_def.33 */
		0b000000100000000000000, /* Rule number: 234 ignore_server_id_list.0 */
		0b000000000000000001000, /* Rule number: 235 ignore_server_id_list.1 */
		0b000000000000001000000, /* Rule number: 236 ignore_server_id_list.2 */
		0b000000000000100000000, /* Rule number: 237 ignore_server_id.0 */
		0b000000000001000000000, /* Rule number: 238 privilege_check_def.0 */
		0b000000000000100000000, /* Rule number: 239 privilege_check_def.1 */
		0b000000000000000010000, /* Rule number: 240 table_primary_key_check_def.0 */
		0b000000000000000001000, /* Rule number: 241 table_primary_key_check_def.1 */
		0b100000000000000000000, /* Rule number: 242 table_primary_key_check_def.2 */
		0b000000000001000000000, /* Rule number: 243 table_primary_key_check_def.3 */
		0b010000000000000000000, /* Rule number: 244 assign_gtids_to_anonymous_transactions_def.0 */
		0b000000001000000000000, /* Rule number: 245 assign_gtids_to_anonymous_transactions_def.1 */
		0b000000000000000000001, /* Rule number: 246 assign_gtids_to_anonymous_transactions_def.2 */
		0b010000000000000000000, /* Rule number: 247 source_tls_ciphersuites_def.0 */
		0b000000000000000100000, /* Rule number: 248 source_tls_ciphersuites_def.1 */
		0b001000000000000000000, /* Rule number: 249 source_file_def.0 */
		0b000000000000100000000, /* Rule number: 250 source_file_def.1 */
		0b000010000000000000000, /* Rule number: 251 source_file_def.2 */
		0b000000000000100000000, /* Rule number: 252 source_file_def.3 */
		0b000000000000000000001, /* Rule number: 253 opt_channel.0 */
		0b000000000001000000000, /* Rule number: 254 opt_channel.1 */
		0b000000000000000001000, /* Rule number: 255 create_table_stmt.0 */
		0b000000000000000000100, /* Rule number: 256 create_table_stmt.1 */
		0b000000000000000000100, /* Rule number: 257 create_table_stmt.2 */
		0b000000000000000000100, /* Rule number: 258 create_table_stmt.3 */
		0b000001000000000000000, /* Rule number: 259 create_role_stmt.0 */
		0b000000010000000000000, /* Rule number: 260 create_resource_group_stmt.0 */
		0b000001000000000000000, /* Rule number: 261 $@6 */
		0b000001000000000000000, /* Rule number: 262 create.0 */
		0b000000100000000000000, /* Rule number: 263 create.1 */
		0b000000000000000010000, /* Rule number: 264 create.2 */
		0b000000000010000000000, /* Rule number: 265 create.3 */
		0b000000000000001000000, /* Rule number: 266 create.4 */
		0b000010000000000000000, /* Rule number: 267 create.5 */
		0b000000000000001000000, /* Rule number: 268 create.6 */
		0b000000100000000000000, /* Rule number: 269 create_srs_stmt.0 */
		0b000000000000010000000, /* Rule number: 270 create_srs_stmt.1 */
		0b001000000000000000000, /* Rule number: 271 srs_attributes.0 */
		0b000000000000100000000, /* Rule number: 272 srs_attributes.1 */
		0b000000000000000010000, /* Rule number: 273 srs_attributes.2 */
		0b000000000000001000000, /* Rule number: 274 srs_attributes.3 */
		0b000001000000000000000, /* Rule number: 275 srs_attributes.4 */
		0b000000001000000000000, /* Rule number: 276 default_role_clause.0 */
		0b000000000100000000000, /* Rule number: 277 default_role_clause.1 */
		0b000000000000100000000, /* Rule number: 278 create_index_stmt.0 */
		0b000000010000000000000, /* Rule number: 279 create_index_stmt.1 */
		0b000000000000001000000, /* Rule number: 280 create_index_stmt.2 */
		0b000000100000000000000, /* Rule number: 281 server_options_list.0 */
		0b001000000000000000000, /* Rule number: 282 server_options_list.1 */
		0b000001000000000000000, /* Rule number: 283 server_option.0 */
		0b000000000000000001000, /* Rule number: 284 server_option.1 */
		0b000000000000001000000, /* Rule number: 285 server_option.2 */
		0b000000000100000000000, /* Rule number: 286 server_option.3 */
		0b000100000000000000000, /* Rule number: 287 server_option.4 */
		0b000000000000000100000, /* Rule number: 288 server_option.5 */
		0b000000000000000000001, /* Rule number: 289 server_option.6 */
		0b100000000000000000000, /* Rule number: 290 $@7 */
		0b000100000000000000000, /* Rule number: 291 event_tail.0 */
		0b000000100000000000000, /* Rule number: 292 $@8 */
		0b000000000000000000001, /* Rule number: 293 ev_schedule_time.0 */
		0b100000000000000000000, /* Rule number: 294 ev_schedule_time.1 */
		0b000000000000000000001, /* Rule number: 295 opt_ev_status.0 */
		0b010000000000000000000, /* Rule number: 296 opt_ev_status.1 */
		0b001000000000000000000, /* Rule number: 297 opt_ev_status.2 */
		0b000000000001000000000, /* Rule number: 298 opt_ev_status.3 */
		0b000000000000000100000, /* Rule number: 299 opt_ev_status.4 */
		0b000000000001000000000, /* Rule number: 300 ev_starts.0 */
		0b000010000000000000000, /* Rule number: 301 ev_starts.1 */
		0b000000001000000000000, /* Rule number: 302 ev_ends.0 */
		0b000000000000010000000, /* Rule number: 303 ev_ends.1 */
		0b000000000001000000000, /* Rule number: 304 opt_ev_on_completion.0 */
		0b000000010000000000000, /* Rule number: 305 opt_ev_on_completion.1 */
		0b000000010000000000000, /* Rule number: 306 ev_on_completion.0 */
		0b000000000000000000010, /* Rule number: 307 ev_on_completion.1 */
		0b000000010000000000000, /* Rule number: 308 opt_ev_comment.0 */
		0b000000000000010000000, /* Rule number: 309 opt_ev_comment.1 */
		0b000000000000000000100, /* Rule number: 310 $@9 */
		0b000100000000000000000, /* Rule number: 311 ev_sql_stmt.0 */
		0b000000000000000001000, /* Rule number: 312 ev_sql_stmt_inner.0 */
		0b010000000000000000000, /* Rule number: 313 ev_sql_stmt_inner.1 */
		0b000000001000000000000, /* Rule number: 314 ev_sql_stmt_inner.2 */
		0b000000000000000000001, /* Rule number: 315 ev_sql_stmt_inner.3 */
		0b000000000000000100000, /* Rule number: 316 ev_sql_stmt_inner.4 */
		0b000000000010000000000, /* Rule number: 317 ev_sql_stmt_inner.5 */
		0b000000000000000000100, /* Rule number: 318 ev_sql_stmt_inner.6 */
		0b000000000000000001000, /* Rule number: 319 ev_sql_stmt_inner.7 */
		0b000000010000000000000, /* Rule number: 320 ev_sql_stmt_inner.8 */
		0b100000000000000000000, /* Rule number: 321 ev_sql_stmt_inner.9 */
		0b000000001000000000000, /* Rule number: 322 ev_sql_stmt_inner.10 */
		0b000000000000010000000, /* Rule number: 323 ev_sql_stmt_inner.11 */
		0b000000000000100000000, /* Rule number: 324 ev_sql_stmt_inner.12 */
		0b000000000000000001000, /* Rule number: 325 sp_name.0 */
		0b001000000000000000000, /* Rule number: 326 sp_name.1 */
		0b000100000000000000000, /* Rule number: 327 sp_a_chistics.0 */
		0b100000000000000000000, /* Rule number: 328 sp_a_chistics.1 */
		0b000000000000000001000, /* Rule number: 329 sp_c_chistics.0 */
		0b000000000001000000000, /* Rule number: 330 sp_c_chistics.1 */
		0b010000000000000000000, /* Rule number: 331 sp_chistic.0 */
		0b000001000000000000000, /* Rule number: 332 sp_chistic.1 */
		0b000001000000000000000, /* Rule number: 333 sp_chistic.2 */
		0b000000000000000010000, /* Rule number: 334 sp_chistic.3 */
		0b000000000100000000000, /* Rule number: 335 sp_chistic.4 */
		0b000000000000000000010, /* Rule number: 336 sp_chistic.5 */
		0b000000000001000000000, /* Rule number: 337 sp_chistic.6 */
		0b000000000000000000100, /* Rule number: 338 sp_chistic.7 */
		0b000000000000000000001, /* Rule number: 339 sp_c_chistic.0 */
		0b001000000000000000000, /* Rule number: 340 sp_c_chistic.1 */
		0b000000000000000100000, /* Rule number: 341 sp_c_chistic.2 */
		0b000000001000000000000, /* Rule number: 342 sp_suid.0 */
		0b000000000000000000001, /* Rule number: 343 sp_suid.1 */
		0b000000000000000010000, /* Rule number: 344 call_stmt.0 */
		0b000000000010000000000, /* Rule number: 345 opt_paren_expr_list.0 */
		0b100000000000000000000, /* Rule number: 346 opt_paren_expr_list.1 */
		0b000000000000010000000, /* Rule number: 347 sp_fdparam_list.0 */
		0b001000000000000000000, /* Rule number: 348 sp_fdparam_list.1 */
		0b000100000000000000000, /* Rule number: 349 sp_fdparams.0 */
		0b000000000100000000000, /* Rule number: 350 sp_fdparams.1 */
		0b000000000000000100000, /* Rule number: 351 sp_fdparam.0 */
		0b000000000000000000001, /* Rule number: 352 sp_pdparam_list.0 */
		0b000000000000010000000, /* Rule number: 353 sp_pdparam_list.1 */
		0b000000100000000000000, /* Rule number: 354 sp_pdparams.0 */
		0b000000000100000000000, /* Rule number: 355 sp_pdparams.1 */
		0b000000000100000000000, /* Rule number: 356 sp_pdparam.0 */
		0b000000000100000000000, /* Rule number: 357 sp_opt_inout.0 */
		0b000010000000000000000, /* Rule number: 358 sp_opt_inout.1 */
		0b000000001000000000000, /* Rule number: 359 sp_opt_inout.2 */
		0b000000000000100000000, /* Rule number: 360 sp_opt_inout.3 */
		0b001000000000000000000, /* Rule number: 361 sp_proc_stmts.0 */
		0b000010000000000000000, /* Rule number: 362 sp_proc_stmts.1 */
		0b000001000000000000000, /* Rule number: 363 sp_proc_stmts1.0 */
		0b000000000000000100000, /* Rule number: 364 sp_proc_stmts1.1 */
		0b000100000000000000000, /* Rule number: 365 sp_decls.0 */
		0b000001000000000000000, /* Rule number: 366 sp_decls.1 */
		0b000000000000000000100, /* Rule number: 367 $@10 */
		0b000000000000001000000, /* Rule number: 368 $@11 */
		0b000000000000001000000, /* Rule number: 369 sp_decl.0 */
		0b000010000000000000000, /* Rule number: 370 sp_decl.1 */
		0b000000000000000000010, /* Rule number: 371 sp_decl.2 */
		0b000000000000000000100, /* Rule number: 372 sp_decl.3 */
		0b000000000000100000000, /* Rule number: 373 sp_handler_type.0 */
		0b000001000000000000000, /* Rule number: 374 sp_handler_type.1 */
		0b000000000000001000000, /* Rule number: 375 sp_hcond_list.0 */
		0b000001000000000000000, /* Rule number: 376 sp_hcond_list.1 */
		0b000000000001000000000, /* Rule number: 377 sp_hcond_element.0 */
		0b001000000000000000000, /* Rule number: 378 sp_cond.0 */
		0b000000000000000010000, /* Rule number: 379 sp_cond.1 */
		0b000000000100000000000, /* Rule number: 380 sqlstate.0 */
		0b000000000000000000010, /* Rule number: 381 opt_value.0 */
		0b001000000000000000000, /* Rule number: 382 opt_value.1 */
		0b000000000000000000100, /* Rule number: 383 sp_hcond.0 */
		0b000000000010000000000, /* Rule number: 384 sp_hcond.1 */
		0b000010000000000000000, /* Rule number: 385 sp_hcond.2 */
		0b000100000000000000000, /* Rule number: 386 sp_hcond.3 */
		0b000010000000000000000, /* Rule number: 387 sp_hcond.4 */
		0b000000001000000000000, /* Rule number: 388 signal_stmt.0 */
		0b000000010000000000000, /* Rule number: 389 signal_value.0 */
		0b000000000010000000000, /* Rule number: 390 signal_value.1 */
		0b000000000000000010000, /* Rule number: 391 opt_signal_value.0 */
		0b001000000000000000000, /* Rule number: 392 opt_signal_value.1 */
		0b000000010000000000000, /* Rule number: 393 opt_set_signal_information.0 */
		0b000000000010000000000, /* Rule number: 394 opt_set_signal_information.1 */
		0b000000001000000000000, /* Rule number: 395 signal_information_item_list.0 */
		0b000010000000000000000, /* Rule number: 396 signal_information_item_list.1 */
		0b100000000000000000000, /* Rule number: 397 signal_allowed_expr.0 */
		0b000000000000000000001, /* Rule number: 398 signal_allowed_expr.1 */
		0b000000000000000001000, /* Rule number: 399 signal_allowed_expr.2 */
		0b000000000000000000001, /* Rule number: 400 signal_condition_information_item_name.0 */
		0b000000000000000010000, /* Rule number: 401 signal_condition_information_item_name.1 */
		0b000000000000000001000, /* Rule number: 402 signal_condition_information_item_name.2 */
		0b000000000000000010000, /* Rule number: 403 signal_condition_information_item_name.3 */
		0b000000000010000000000, /* Rule number: 404 signal_condition_information_item_name.4 */
		0b000000000000000000100, /* Rule number: 405 signal_condition_information_item_name.5 */
		0b100000000000000000000, /* Rule number: 406 signal_condition_information_item_name.6 */
		0b001000000000000000000, /* Rule number: 407 signal_condition_information_item_name.7 */
		0b000000000000000000001, /* Rule number: 408 signal_condition_information_item_name.8 */
		0b000000000000000100000, /* Rule number: 409 signal_condition_information_item_name.9 */
		0b000000000000000000001, /* Rule number: 410 signal_condition_information_item_name.10 */
		0b000000000000000001000, /* Rule number: 411 signal_condition_information_item_name.11 */
		0b000000000010000000000, /* Rule number: 412 resignal_stmt.0 */
		0b100000000000000000000, /* Rule number: 413 get_diagnostics.0 */
		0b100000000000000000000, /* Rule number: 414 which_area.0 */
		0b001000000000000000000, /* Rule number: 415 which_area.1 */
		0b000100000000000000000, /* Rule number: 416 which_area.2 */
		0b000000000100000000000, /* Rule number: 417 diagnostics_information.0 */
		0b000100000000000000000, /* Rule number: 418 diagnostics_information.1 */
		0b000000100000000000000, /* Rule number: 419 statement_information.0 */
		0b000000000000010000000, /* Rule number: 420 statement_information.1 */
		0b000000000000000000010, /* Rule number: 421 statement_information_item.0 */
		0b000000000001000000000, /* Rule number: 422 simple_target_specification.0 */
		0b000000000001000000000, /* Rule number: 423 simple_target_specification.1 */
		0b000010000000000000000, /* Rule number: 424 statement_information_item_name.0 */
		0b001000000000000000000, /* Rule number: 425 statement_information_item_name.1 */
		0b000000010000000000000, /* Rule number: 426 condition_number.0 */
		0b000000000100000000000, /* Rule number: 427 condition_information.0 */
		0b000000000010000000000, /* Rule number: 428 condition_information.1 */
		0b000000001000000000000, /* Rule number: 429 condition_information_item.0 */
		0b000000100000000000000, /* Rule number: 430 condition_information_item_name.0 */
		0b000000000000000001000, /* Rule number: 431 condition_information_item_name.1 */
		0b000000000000000010000, /* Rule number: 432 condition_information_item_name.2 */
		0b000000010000000000000, /* Rule number: 433 condition_information_item_name.3 */
		0b000010000000000000000, /* Rule number: 434 condition_information_item_name.4 */
		0b000000000000001000000, /* Rule number: 435 condition_information_item_name.5 */
		0b000100000000000000000, /* Rule number: 436 condition_information_item_name.6 */
		0b000000000000000010000, /* Rule number: 437 condition_information_item_name.7 */
		0b000000000000001000000, /* Rule number: 438 condition_information_item_name.8 */
		0b000000000000100000000, /* Rule number: 439 condition_information_item_name.9 */
		0b000010000000000000000, /* Rule number: 440 condition_information_item_name.10 */
		0b000000000000000010000, /* Rule number: 441 condition_information_item_name.11 */
		0b000000001000000000000, /* Rule number: 442 condition_information_item_name.12 */
		0b100000000000000000000, /* Rule number: 443 sp_decl_idents.0 */
		0b000000010000000000000, /* Rule number: 444 sp_decl_idents.1 */
		0b000000000001000000000, /* Rule number: 445 sp_opt_default.0 */
		0b000001000000000000000, /* Rule number: 446 sp_opt_default.1 */
		0b000000000000100000000, /* Rule number: 447 sp_proc_stmt.0 */
		0b010000000000000000000, /* Rule number: 448 sp_proc_stmt.1 */
		0b000000000000000000001, /* Rule number: 449 sp_proc_stmt.2 */
		0b000000000000000001000, /* Rule number: 450 sp_proc_stmt.3 */
		0b000000100000000000000, /* Rule number: 451 sp_proc_stmt.4 */
		0b000000000001000000000, /* Rule number: 452 sp_proc_stmt.5 */
		0b000001000000000000000, /* Rule number: 453 sp_proc_stmt.6 */
		0b000010000000000000000, /* Rule number: 454 sp_proc_stmt.7 */
		0b100000000000000000000, /* Rule number: 455 sp_proc_stmt.8 */
		0b001000000000000000000, /* Rule number: 456 sp_proc_stmt.9 */
		0b000000000010000000000, /* Rule number: 457 sp_proc_stmt.10 */
		0b000000000000010000000, /* Rule number: 458 sp_proc_stmt.11 */
		0b000100000000000000000, /* Rule number: 459 sp_proc_stmt.12 */
		0b010000000000000000000, /* Rule number: 460 $@12 */
		0b000000100000000000000, /* Rule number: 461 sp_proc_stmt_if.0 */
		0b000000010000000000000, /* Rule number: 462 $@13 */
		0b000000000000000010000, /* Rule number: 463 sp_proc_stmt_statement.0 */
		0b000000000000000010000, /* Rule number: 464 $@14 */
		0b000010000000000000000, /* Rule number: 465 sp_proc_stmt_return.0 */
		0b100000000000000000000, /* Rule number: 466 $@15 */
		0b000000000000000000100, /* Rule number: 467 sp_proc_stmt_unlabeled.0 */
		0b000000000100000000000, /* Rule number: 468 sp_proc_stmt_leave.0 */
		0b000000100000000000000, /* Rule number: 469 sp_proc_stmt_iterate.0 */
		0b000000000000000001000, /* Rule number: 470 sp_proc_stmt_open.0 */
		0b001000000000000000000, /* Rule number: 471 $@16 */
		0b000000000000001000000, /* Rule number: 472 sp_proc_stmt_fetch.0 */
		0b000000000000001000000, /* Rule number: 473 sp_proc_stmt_close.0 */
		0b001000000000000000000, /* Rule number: 474 sp_opt_fetch_noise.0 */
		0b000000001000000000000, /* Rule number: 475 sp_opt_fetch_noise.1 */
		0b000000000000010000000, /* Rule number: 476 sp_opt_fetch_noise.2 */
		0b000000000100000000000, /* Rule number: 477 sp_fetch_list.0 */
		0b000000010000000000000, /* Rule number: 478 sp_fetch_list.1 */
		0b000000000000000000100, /* Rule number: 479 $@17 */
		0b000000000000000000001, /* Rule number: 480 $@18 */
		0b000000000000000100000, /* Rule number: 481 $@19 */
		0b000000000000010000000, /* Rule number: 482 sp_if.0 */
		0b010000000000000000000, /* Rule number: 483 sp_elseifs.0 */
		0b100000000000000000000, /* Rule number: 484 sp_elseifs.1 */
		0b010000000000000000000, /* Rule number: 485 sp_elseifs.2 */
		0b000000010000000000000, /* Rule number: 486 case_stmt_specification.0 */
		0b000010000000000000000, /* Rule number: 487 case_stmt_specification.1 */
		0b000000000010000000000, /* Rule number: 488 $@20 */
		0b000000000000000100000, /* Rule number: 489 $@21 */
		0b000000000001000000000, /* Rule number: 490 simple_case_stmt.0 */
		0b010000000000000000000, /* Rule number: 491 $@22 */
		0b000000000000000000001, /* Rule number: 492 searched_case_stmt.0 */
		0b000000001000000000000, /* Rule number: 493 simple_when_clause_list.0 */
		0b000000000000001000000, /* Rule number: 494 simple_when_clause_list.1 */
		0b000000000000000000010, /* Rule number: 495 searched_when_clause_list.0 */
		0b000100000000000000000, /* Rule number: 496 searched_when_clause_list.1 */
		0b000000000000001000000, /* Rule number: 497 $@23 */
		0b000000000000000000001, /* Rule number: 498 $@24 */
		0b000000000000001000000, /* Rule number: 499 simple_when_clause.0 */
		0b000000000010000000000, /* Rule number: 500 $@25 */
		0b000000000000100000000, /* Rule number: 501 $@26 */
		0b000000000000001000000, /* Rule number: 502 searched_when_clause.0 */
		0b000000000000010000000, /* Rule number: 503 else_clause_opt.0 */
		0b000000100000000000000, /* Rule number: 504 else_clause_opt.1 */
		0b001000000000000000000, /* Rule number: 505 $@27 */
		0b000000000000000000100, /* Rule number: 506 sp_labeled_control.0 */
		0b000000000000000000100, /* Rule number: 507 sp_opt_label.0 */
		0b000000000001000000000, /* Rule number: 508 sp_opt_label.1 */
		0b000001000000000000000, /* Rule number: 509 $@28 */
		0b000000000000000001000, /* Rule number: 510 sp_labeled_block.0 */
		0b000000000000000000001, /* Rule number: 511 $@29 */
		0b000000000000000001000, /* Rule number: 512 sp_unlabeled_block.0 */
		0b000010000000000000000, /* Rule number: 513 $@30 */
		0b000000000001000000000, /* Rule number: 514 sp_block_content.0 */
		0b000001000000000000000, /* Rule number: 515 $@31 */
		0b000100000000000000000, /* Rule number: 516 $@32 */
		0b000000000000010000000, /* Rule number: 517 $@33 */
		0b000001000000000000000, /* Rule number: 518 $@34 */
		0b000000010000000000000, /* Rule number: 519 sp_unlabeled_control.0 */
		0b100000000000000000000, /* Rule number: 520 sp_unlabeled_control.1 */
		0b000000000010000000000, /* Rule number: 521 sp_unlabeled_control.2 */
		0b000000000000100000000, /* Rule number: 522 trg_action_time.0 */
		0b000000000000000100000, /* Rule number: 523 trg_action_time.1 */
		0b000010000000000000000, /* Rule number: 524 trg_event.0 */
		0b000000000000100000000, /* Rule number: 525 trg_event.1 */
		0b000000000000010000000, /* Rule number: 526 trg_event.2 */
		0b100000000000000000000, /* Rule number: 527 opt_ts_datafile_name.0 */
		0b000000000000000000001, /* Rule number: 528 opt_ts_datafile_name.1 */
		0b100000000000000000000, /* Rule number: 529 opt_logfile_group_name.0 */
		0b000000000001000000000, /* Rule number: 530 opt_logfile_group_name.1 */
		0b000000000001000000000, /* Rule number: 531 opt_tablespace_options.0 */
		0b010000000000000000000, /* Rule number: 532 opt_tablespace_options.1 */
		0b100000000000000000000, /* Rule number: 533 tablespace_option_list.0 */
		0b000000010000000000000, /* Rule number: 534 tablespace_option_list.1 */
		0b000000100000000000000, /* Rule number: 535 tablespace_option.0 */
		0b000000000000000010000, /* Rule number: 536 tablespace_option.1 */
		0b000100000000000000000, /* Rule number: 537 tablespace_option.2 */
		0b000000100000000000000, /* Rule number: 538 tablespace_option.3 */
		0b000010000000000000000, /* Rule number: 539 tablespace_option.4 */
		0b000000001000000000000, /* Rule number: 540 tablespace_option.5 */
		0b000000000000001000000, /* Rule number: 541 tablespace_option.6 */
		0b000000000100000000000, /* Rule number: 542 tablespace_option.7 */
		0b000000000000000000010, /* Rule number: 543 tablespace_option.8 */
		0b001000000000000000000, /* Rule number: 544 tablespace_option.9 */
		0b000000000000100000000, /* Rule number: 545 tablespace_option.10 */
		0b000000000000000000001, /* Rule number: 546 opt_alter_tablespace_options.0 */
		0b000000000010000000000, /* Rule number: 547 opt_alter_tablespace_options.1 */
		0b000000000000000001000, /* Rule number: 548 alter_tablespace_option_list.0 */
		0b010000000000000000000, /* Rule number: 549 alter_tablespace_option_list.1 */
		0b000001000000000000000, /* Rule number: 550 alter_tablespace_option.0 */
		0b000000000000100000000, /* Rule number: 551 alter_tablespace_option.1 */
		0b000000000000000001000, /* Rule number: 552 alter_tablespace_option.2 */
		0b000000000000000000100, /* Rule number: 553 alter_tablespace_option.3 */
		0b000000000000010000000, /* Rule number: 554 alter_tablespace_option.4 */
		0b000000000000000001000, /* Rule number: 555 alter_tablespace_option.5 */
		0b000000000000001000000, /* Rule number: 556 alter_tablespace_option.6 */
		0b000000000000000001000, /* Rule number: 557 opt_undo_tablespace_options.0 */
		0b001000000000000000000, /* Rule number: 558 opt_undo_tablespace_options.1 */
		0b000000001000000000000, /* Rule number: 559 undo_tablespace_option_list.0 */
		0b000000000000010000000, /* Rule number: 560 undo_tablespace_option_list.1 */
		0b000000000000000100000, /* Rule number: 561 undo_tablespace_option.0 */
		0b000001000000000000000, /* Rule number: 562 opt_logfile_group_options.0 */
		0b000000001000000000000, /* Rule number: 563 opt_logfile_group_options.1 */
		0b000000000000000000010, /* Rule number: 564 logfile_group_option_list.0 */
		0b000000000000000000100, /* Rule number: 565 logfile_group_option_list.1 */
		0b010000000000000000000, /* Rule number: 566 logfile_group_option.0 */
		0b000000000000010000000, /* Rule number: 567 logfile_group_option.1 */
		0b100000000000000000000, /* Rule number: 568 logfile_group_option.2 */
		0b000000000000000000001, /* Rule number: 569 logfile_group_option.3 */
		0b000000000000000000010, /* Rule number: 570 logfile_group_option.4 */
		0b000000010000000000000, /* Rule number: 571 logfile_group_option.5 */
		0b000010000000000000000, /* Rule number: 572 logfile_group_option.6 */
		0b000000000000100000000, /* Rule number: 573 opt_alter_logfile_group_options.0 */
		0b000010000000000000000, /* Rule number: 574 opt_alter_logfile_group_options.1 */
		0b100000000000000000000, /* Rule number: 575 alter_logfile_group_option_list.0 */
		0b000001000000000000000, /* Rule number: 576 alter_logfile_group_option_list.1 */
		0b001000000000000000000, /* Rule number: 577 alter_logfile_group_option.0 */
		0b000000000000000100000, /* Rule number: 578 alter_logfile_group_option.1 */
		0b000000000100000000000, /* Rule number: 579 alter_logfile_group_option.2 */
		0b000000000001000000000, /* Rule number: 580 ts_datafile.0 */
		0b000000000000000000001, /* Rule number: 581 undo_tablespace_state.0 */
		0b000000000010000000000, /* Rule number: 582 undo_tablespace_state.1 */
		0b000000001000000000000, /* Rule number: 583 lg_undofile.0 */
		0b000000000001000000000, /* Rule number: 584 ts_option_initial_size.0 */
		0b000000010000000000000, /* Rule number: 585 ts_option_autoextend_size.0 */
		0b000100000000000000000, /* Rule number: 586 option_autoextend_size.0 */
		0b000000000000000100000, /* Rule number: 587 ts_option_max_size.0 */
		0b000000000000000000010, /* Rule number: 588 ts_option_extent_size.0 */
		0b000000010000000000000, /* Rule number: 589 ts_option_undo_buffer_size.0 */
		0b000000000000000010000, /* Rule number: 590 ts_option_redo_buffer_size.0 */
		0b000000000000000010000, /* Rule number: 591 ts_option_nodegroup.0 */
		0b000000100000000000000, /* Rule number: 592 ts_option_comment.0 */
		0b000000010000000000000, /* Rule number: 593 ts_option_engine.0 */
		0b000000000000010000000, /* Rule number: 594 ts_option_file_block_size.0 */
		0b000000000000000010000, /* Rule number: 595 ts_option_wait.0 */
		0b001000000000000000000, /* Rule number: 596 ts_option_wait.1 */
		0b000000010000000000000, /* Rule number: 597 ts_option_encryption.0 */
		0b000010000000000000000, /* Rule number: 598 ts_option_engine_attribute.0 */
		0b001000000000000000000, /* Rule number: 599 size_number.0 */
		0b000001000000000000000, /* Rule number: 600 size_number.1 */
		0b000000000000010000000, /* Rule number: 601 opt_create_table_options_etc.0 */
		0b100000000000000000000, /* Rule number: 602 opt_create_table_options_etc.1 */
		0b000100000000000000000, /* Rule number: 603 opt_create_partitioning_etc.0 */
		0b000000000001000000000, /* Rule number: 604 opt_create_partitioning_etc.1 */
		0b000000000000000100000, /* Rule number: 605 opt_duplicate_as_qe.0 */
		0b000000000000000100000, /* Rule number: 606 opt_duplicate_as_qe.1 */
		0b000010000000000000000, /* Rule number: 607 opt_duplicate_as_qe.2 */
		0b000000000000001000000, /* Rule number: 608 as_create_query_expression.0 */
		0b000000000000100000000, /* Rule number: 609 as_create_query_expression.1 */
		0b000000000010000000000, /* Rule number: 610 partition_clause.0 */
		0b100000000000000000000, /* Rule number: 611 part_type_def.0 */
		0b000000000000010000000, /* Rule number: 612 part_type_def.1 */
		0b000100000000000000000, /* Rule number: 613 part_type_def.2 */
		0b000001000000000000000, /* Rule number: 614 part_type_def.3 */
		0b100000000000000000000, /* Rule number: 615 part_type_def.4 */
		0b000000000000010000000, /* Rule number: 616 part_type_def.5 */
		0b000000000000000001000, /* Rule number: 617 opt_linear.0 */
		0b000000000010000000000, /* Rule number: 618 opt_linear.1 */
		0b000000010000000000000, /* Rule number: 619 opt_key_algo.0 */
		0b000000010000000000000, /* Rule number: 620 opt_key_algo.1 */
		0b001000000000000000000, /* Rule number: 621 opt_num_parts.0 */
		0b000000000000000000010, /* Rule number: 622 opt_num_parts.1 */
		0b000000000000100000000, /* Rule number: 623 opt_sub_part.0 */
		0b000000000000000000001, /* Rule number: 624 opt_sub_part.1 */
		0b001000000000000000000, /* Rule number: 625 opt_sub_part.2 */
		0b000000010000000000000, /* Rule number: 626 opt_name_list.0 */
		0b000001000000000000000, /* Rule number: 627 opt_name_list.1 */
		0b000000010000000000000, /* Rule number: 628 name_list.0 */
		0b000000000000000000100, /* Rule number: 629 name_list.1 */
		0b000000000100000000000, /* Rule number: 630 opt_num_subparts.0 */
		0b000100000000000000000, /* Rule number: 631 opt_num_subparts.1 */
		0b100000000000000000000, /* Rule number: 632 opt_part_defs.0 */
		0b000000000000000000100, /* Rule number: 633 opt_part_defs.1 */
		0b000000000100000000000, /* Rule number: 634 part_def_list.0 */
		0b000000000000000000001, /* Rule number: 635 part_def_list.1 */
		0b000000000000000000010, /* Rule number: 636 part_definition.0 */
		0b000001000000000000000, /* Rule number: 637 opt_part_values.0 */
		0b000100000000000000000, /* Rule number: 638 opt_part_values.1 */
		0b000000000000000100000, /* Rule number: 639 opt_part_values.2 */
		0b000000001000000000000, /* Rule number: 640 part_func_max.0 */
		0b000010000000000000000, /* Rule number: 641 part_func_max.1 */
		0b000000001000000000000, /* Rule number: 642 part_values_in.0 */
		0b010000000000000000000, /* Rule number: 643 part_values_in.1 */
		0b000000000000000000001, /* Rule number: 644 part_value_list.0 */
		0b001000000000000000000, /* Rule number: 645 part_value_list.1 */
		0b000000000000001000000, /* Rule number: 646 $@35 */
		0b000000000001000000000, /* Rule number: 647 part_value_item_list_paren.0 */
		0b000000000000010000000, /* Rule number: 648 part_value_item_list.0 */
		0b000000001000000000000, /* Rule number: 649 part_value_item_list.1 */
		0b000000000001000000000, /* Rule number: 650 part_value_item.0 */
		0b100000000000000000000, /* Rule number: 651 part_value_item.1 */
		0b000000000010000000000, /* Rule number: 652 opt_sub_partition.0 */
		0b000000000100000000000, /* Rule number: 653 opt_sub_partition.1 */
		0b000000000000000001000, /* Rule number: 654 sub_part_list.0 */
		0b010000000000000000000, /* Rule number: 655 sub_part_list.1 */
		0b000000000001000000000, /* Rule number: 656 sub_part_definition.0 */
		0b000010000000000000000, /* Rule number: 657 opt_part_options.0 */
		0b010000000000000000000, /* Rule number: 658 opt_part_options.1 */
		0b000000000100000000000, /* Rule number: 659 part_option_list.0 */
		0b000000000000001000000, /* Rule number: 660 part_option_list.1 */
		0b001000000000000000000, /* Rule number: 661 part_option.0 */
		0b000000000100000000000, /* Rule number: 662 part_option.1 */
		0b000000000001000000000, /* Rule number: 663 part_option.2 */
		0b010000000000000000000, /* Rule number: 664 part_option.3 */
		0b001000000000000000000, /* Rule number: 665 part_option.4 */
		0b000000000000000001000, /* Rule number: 666 part_option.5 */
		0b000001000000000000000, /* Rule number: 667 part_option.6 */
		0b000000000000000100000, /* Rule number: 668 part_option.7 */
		0b000000100000000000000, /* Rule number: 669 alter_database_options.0 */
		0b000000000000000000100, /* Rule number: 670 alter_database_options.1 */
		0b000000000000001000000, /* Rule number: 671 alter_database_option.0 */
		0b000000000000000001000, /* Rule number: 672 alter_database_option.1 */
		0b000000000000000010000, /* Rule number: 673 opt_create_database_options.0 */
		0b000000000000000010000, /* Rule number: 674 opt_create_database_options.1 */
		0b000001000000000000000, /* Rule number: 675 create_database_options.0 */
		0b000000000000000001000, /* Rule number: 676 create_database_options.1 */
		0b000000010000000000000, /* Rule number: 677 create_database_option.0 */
		0b000000000000000000001, /* Rule number: 678 create_database_option.1 */
		0b001000000000000000000, /* Rule number: 679 create_database_option.2 */
		0b000010000000000000000, /* Rule number: 680 opt_if_not_exists.0 */
		0b000000000000001000000, /* Rule number: 681 opt_if_not_exists.1 */
		0b010000000000000000000, /* Rule number: 682 create_table_options_space_separated.0 */
		0b000000010000000000000, /* Rule number: 683 create_table_options_space_separated.1 */
		0b000000000000000000010, /* Rule number: 684 create_table_options.0 */
		0b100000000000000000000, /* Rule number: 685 create_table_options.1 */
		0b000000000000000001000, /* Rule number: 686 opt_comma.0 */
		0b000000000010000000000, /* Rule number: 687 opt_comma.1 */
		0b000000000000000010000, /* Rule number: 688 create_table_option.0 */
		0b000000000100000000000, /* Rule number: 689 create_table_option.1 */
		0b100000000000000000000, /* Rule number: 690 create_table_option.2 */
		0b000000000000000000010, /* Rule number: 691 create_table_option.3 */
		0b000000000001000000000, /* Rule number: 692 create_table_option.4 */
		0b000000000000000000010, /* Rule number: 693 create_table_option.5 */
		0b000000000000000000100, /* Rule number: 694 create_table_option.6 */
		0b000000000000100000000, /* Rule number: 695 create_table_option.7 */
		0b000000000000000000100, /* Rule number: 696 create_table_option.8 */
		0b100000000000000000000, /* Rule number: 697 create_table_option.9 */
		0b000000000000100000000, /* Rule number: 698 create_table_option.10 */
		0b000000000000010000000, /* Rule number: 699 create_table_option.11 */
		0b000000000000000010000, /* Rule number: 700 create_table_option.12 */
		0b000000000000001000000, /* Rule number: 701 create_table_option.13 */
		0b000000000000000000100, /* Rule number: 702 create_table_option.14 */
		0b000000000000000100000, /* Rule number: 703 create_table_option.15 */
		0b000000000010000000000, /* Rule number: 704 create_table_option.16 */
		0b000000000000000000010, /* Rule number: 705 create_table_option.17 */
		0b000000000010000000000, /* Rule number: 706 create_table_option.18 */
		0b000000000000000100000, /* Rule number: 707 create_table_option.19 */
		0b000000000000100000000, /* Rule number: 708 create_table_option.20 */
		0b000000000001000000000, /* Rule number: 709 create_table_option.21 */
		0b100000000000000000000, /* Rule number: 710 create_table_option.22 */
		0b100000000000000000000, /* Rule number: 711 create_table_option.23 */
		0b000000010000000000000, /* Rule number: 712 create_table_option.24 */
		0b000000000000000010000, /* Rule number: 713 create_table_option.25 */
		0b000000000000001000000, /* Rule number: 714 create_table_option.26 */
		0b000001000000000000000, /* Rule number: 715 create_table_option.27 */
		0b000000010000000000000, /* Rule number: 716 create_table_option.28 */
		0b000000000000001000000, /* Rule number: 717 create_table_option.29 */
		0b000000000000000000010, /* Rule number: 718 create_table_option.30 */
		0b000000000000000001000, /* Rule number: 719 create_table_option.31 */
		0b000000000000000010000, /* Rule number: 720 create_table_option.32 */
		0b001000000000000000000, /* Rule number: 721 create_table_option.33 */
		0b000000000000000001000, /* Rule number: 722 create_table_option.34 */
		0b010000000000000000000, /* Rule number: 723 ternary_option.0 */
		0b000000000000001000000, /* Rule number: 724 ternary_option.1 */
		0b001000000000000000000, /* Rule number: 725 default_charset.0 */
		0b000000000000000000100, /* Rule number: 726 default_collation.0 */
		0b000000000000000100000, /* Rule number: 727 default_encryption.0 */
		0b000000000100000000000, /* Rule number: 728 row_types.0 */
		0b000000000000000010000, /* Rule number: 729 row_types.1 */
		0b000010000000000000000, /* Rule number: 730 row_types.2 */
		0b000000000000010000000, /* Rule number: 731 row_types.3 */
		0b000000000000100000000, /* Rule number: 732 row_types.4 */
		0b000010000000000000000, /* Rule number: 733 row_types.5 */
		0b000000000000000010000, /* Rule number: 734 merge_insert_types.0 */
		0b000001000000000000000, /* Rule number: 735 merge_insert_types.1 */
		0b000000000000000000001, /* Rule number: 736 merge_insert_types.2 */
		0b000000010000000000000, /* Rule number: 737 udf_type.0 */
		0b000000000000010000000, /* Rule number: 738 udf_type.1 */
		0b010000000000000000000, /* Rule number: 739 udf_type.2 */
		0b100000000000000000000, /* Rule number: 740 udf_type.3 */
		0b000000000000000100000, /* Rule number: 741 table_element_list.0 */
		0b000000000000010000000, /* Rule number: 742 table_element_list.1 */
		0b000000000001000000000, /* Rule number: 743 table_element.0 */
		0b000000010000000000000, /* Rule number: 744 table_element.1 */
		0b000000000001000000000, /* Rule number: 745 column_def.0 */
		0b010000000000000000000, /* Rule number: 746 opt_references.0 */
		0b000001000000000000000, /* Rule number: 747 opt_references.1 */
		0b000000000000000000001, /* Rule number: 748 table_constraint_def.0 */
		0b100000000000000000000, /* Rule number: 749 table_constraint_def.1 */
		0b000000100000000000000, /* Rule number: 750 table_constraint_def.2 */
		0b000000000000000000010, /* Rule number: 751 table_constraint_def.3 */
		0b000000000000000000100, /* Rule number: 752 table_constraint_def.4 */
		0b000000000000000010000, /* Rule number: 753 table_constraint_def.5 */
		0b010000000000000000000, /* Rule number: 754 check_constraint.0 */
		0b000000000000100000000, /* Rule number: 755 opt_constraint_name.0 */
		0b000000000010000000000, /* Rule number: 756 opt_constraint_name.1 */
		0b000000000010000000000, /* Rule number: 757 opt_not.0 */
		0b000000000000000010000, /* Rule number: 758 opt_not.1 */
		0b000000001000000000000, /* Rule number: 759 opt_constraint_enforcement.0 */
		0b001000000000000000000, /* Rule number: 760 opt_constraint_enforcement.1 */
		0b000000010000000000000, /* Rule number: 761 constraint_enforcement.0 */
		0b000000000000000001000, /* Rule number: 762 field_def.0 */
		0b000000000000000100000, /* Rule number: 763 field_def.1 */
		0b000000000000010000000, /* Rule number: 764 opt_generated_always.0 */
		0b000000100000000000000, /* Rule number: 765 opt_generated_always.1 */
		0b000000000000000000001, /* Rule number: 766 opt_stored_attribute.0 */
		0b000000001000000000000, /* Rule number: 767 opt_stored_attribute.1 */
		0b000000000000000001000, /* Rule number: 768 opt_stored_attribute.2 */
		0b000000010000000000000, /* Rule number: 769 type.0 */
		0b000000000010000000000, /* Rule number: 770 type.1 */
		0b000000000100000000000, /* Rule number: 771 type.2 */
		0b000001000000000000000, /* Rule number: 772 type.3 */
		0b000000001000000000000, /* Rule number: 773 type.4 */
		0b000000100000000000000, /* Rule number: 774 type.5 */
		0b000000000000000001000, /* Rule number: 775 type.6 */
		0b000000000000001000000, /* Rule number: 776 type.7 */
		0b100000000000000000000, /* Rule number: 777 type.8 */
		0b100000000000000000000, /* Rule number: 778 type.9 */
		0b000000010000000000000, /* Rule number: 779 type.10 */
		0b100000000000000000000, /* Rule number: 780 type.11 */
		0b000100000000000000000, /* Rule number: 781 type.12 */
		0b000000000000000010000, /* Rule number: 782 type.13 */
		0b000000000000000000001, /* Rule number: 783 type.14 */
		0b100000000000000000000, /* Rule number: 784 type.15 */
		0b000000001000000000000, /* Rule number: 785 type.16 */
		0b001000000000000000000, /* Rule number: 786 type.17 */
		0b000000100000000000000, /* Rule number: 787 type.18 */
		0b001000000000000000000, /* Rule number: 788 type.19 */
		0b000000000000000010000, /* Rule number: 789 type.20 */
		0b000000000000000001000, /* Rule number: 790 type.21 */
		0b000000000000010000000, /* Rule number: 791 type.22 */
		0b000000000000010000000, /* Rule number: 792 type.23 */
		0b000010000000000000000, /* Rule number: 793 type.24 */
		0b000000000000000100000, /* Rule number: 794 type.25 */
		0b000000000000000000001, /* Rule number: 795 type.26 */
		0b000000000000000001000, /* Rule number: 796 type.27 */
		0b000000010000000000000, /* Rule number: 797 type.28 */
		0b000000000000000000100, /* Rule number: 798 type.29 */
		0b000000000000001000000, /* Rule number: 799 type.30 */
		0b000000000000000010000, /* Rule number: 800 type.31 */
		0b000000000000000001000, /* Rule number: 801 type.32 */
		0b000000010000000000000, /* Rule number: 802 type.33 */
		0b000000010000000000000, /* Rule number: 803 type.34 */
		0b000000000000000000100, /* Rule number: 804 type.35 */
		0b000100000000000000000, /* Rule number: 805 type.36 */
		0b000000000000000010000, /* Rule number: 806 spatial_type.0 */
		0b100000000000000000000, /* Rule number: 807 spatial_type.1 */
		0b000000000100000000000, /* Rule number: 808 spatial_type.2 */
		0b000000000000010000000, /* Rule number: 809 spatial_type.3 */
		0b000000000000000010000, /* Rule number: 810 spatial_type.4 */
		0b000000000100000000000, /* Rule number: 811 spatial_type.5 */
		0b010000000000000000000, /* Rule number: 812 spatial_type.6 */
		0b000000000000000000001, /* Rule number: 813 spatial_type.7 */
		0b000000000000000010000, /* Rule number: 814 nchar.0 */
		0b000000000000000100000, /* Rule number: 815 nchar.1 */
		0b000000000000001000000, /* Rule number: 816 varchar.0 */
		0b000000000010000000000, /* Rule number: 817 varchar.1 */
		0b000100000000000000000, /* Rule number: 818 nvarchar.0 */
		0b001000000000000000000, /* Rule number: 819 nvarchar.1 */
		0b000000000000000000010, /* Rule number: 820 nvarchar.2 */
		0b000001000000000000000, /* Rule number: 821 nvarchar.3 */
		0b000000000000010000000, /* Rule number: 822 nvarchar.4 */
		0b001000000000000000000, /* Rule number: 823 int_type.0 */
		0b100000000000000000000, /* Rule number: 824 int_type.1 */
		0b000000001000000000000, /* Rule number: 825 int_type.2 */
		0b000000100000000000000, /* Rule number: 826 int_type.3 */
		0b000000000001000000000, /* Rule number: 827 int_type.4 */
		0b100000000000000000000, /* Rule number: 828 real_type.0 */
		0b000000000001000000000, /* Rule number: 829 real_type.1 */
		0b010000000000000000000, /* Rule number: 830 opt_PRECISION.0 */
		0b000000000000001000000, /* Rule number: 831 opt_PRECISION.1 */
		0b000000000000000000100, /* Rule number: 832 numeric_type.0 */
		0b000100000000000000000, /* Rule number: 833 numeric_type.1 */
		0b000000000010000000000, /* Rule number: 834 numeric_type.2 */
		0b001000000000000000000, /* Rule number: 835 numeric_type.3 */
		0b000000000000000001000, /* Rule number: 836 standard_float_options.0 */
		0b000000100000000000000, /* Rule number: 837 standard_float_options.1 */
		0b000000000010000000000, /* Rule number: 838 float_options.0 */
		0b000000000000001000000, /* Rule number: 839 float_options.1 */
		0b000000000000001000000, /* Rule number: 840 float_options.2 */
		0b000000000000001000000, /* Rule number: 841 precision.0 */
		0b000000010000000000000, /* Rule number: 842 type_datetime_precision.0 */
		0b000000000010000000000, /* Rule number: 843 type_datetime_precision.1 */
		0b000000000000010000000, /* Rule number: 844 func_datetime_precision.0 */
		0b000000000000100000000, /* Rule number: 845 func_datetime_precision.1 */
		0b000000001000000000000, /* Rule number: 846 func_datetime_precision.2 */
		0b000000000100000000000, /* Rule number: 847 field_options.0 */
		0b000000000010000000000, /* Rule number: 848 field_options.1 */
		0b000000000000001000000, /* Rule number: 849 field_opt_list.0 */
		0b000100000000000000000, /* Rule number: 850 field_opt_list.1 */
		0b000000000000000100000, /* Rule number: 851 field_option.0 */
		0b000000000010000000000, /* Rule number: 852 field_option.1 */
		0b010000000000000000000, /* Rule number: 853 field_option.2 */
		0b000000000010000000000, /* Rule number: 854 field_length.0 */
		0b000000000010000000000, /* Rule number: 855 field_length.1 */
		0b000000000000000010000, /* Rule number: 856 field_length.2 */
		0b000000000000100000000, /* Rule number: 857 field_length.3 */
		0b000000000000000001000, /* Rule number: 858 opt_field_length.0 */
		0b000000001000000000000, /* Rule number: 859 opt_field_length.1 */
		0b000000000001000000000, /* Rule number: 860 opt_precision.0 */
		0b000000000000000010000, /* Rule number: 861 opt_precision.1 */
		0b000000001000000000000, /* Rule number: 862 opt_column_attribute_list.0 */
		0b000010000000000000000, /* Rule number: 863 opt_column_attribute_list.1 */
		0b000000000000000000001, /* Rule number: 864 column_attribute_list.0 */
		0b000000000000000010000, /* Rule number: 865 column_attribute_list.1 */
		0b000001000000000000000, /* Rule number: 866 column_attribute.0 */
		0b000000000010000000000, /* Rule number: 867 column_attribute.1 */
		0b000000000000100000000, /* Rule number: 868 column_attribute.2 */
		0b000000000000100000000, /* Rule number: 869 column_attribute.3 */
		0b000000000000000000010, /* Rule number: 870 column_attribute.4 */
		0b000100000000000000000, /* Rule number: 871 column_attribute.5 */
		0b000000000000100000000, /* Rule number: 872 column_attribute.6 */
		0b000000100000000000000, /* Rule number: 873 column_attribute.7 */
		0b000000000000000001000, /* Rule number: 874 column_attribute.8 */
		0b000000000000000001000, /* Rule number: 875 column_attribute.9 */
		0b000000000000100000000, /* Rule number: 876 column_attribute.10 */
		0b001000000000000000000, /* Rule number: 877 column_attribute.11 */
		0b000000000000000010000, /* Rule number: 878 column_attribute.12 */
		0b000001000000000000000, /* Rule number: 879 column_attribute.13 */
		0b000000000000000010000, /* Rule number: 880 column_attribute.14 */
		0b000100000000000000000, /* Rule number: 881 column_attribute.15 */
		0b000010000000000000000, /* Rule number: 882 column_attribute.16 */
		0b000000000000010000000, /* Rule number: 883 column_attribute.17 */
		0b000000000000000001000, /* Rule number: 884 column_attribute.18 */
		0b000000000000000000010, /* Rule number: 885 column_attribute.19 */
		0b000000001000000000000, /* Rule number: 886 column_attribute.20 */
		0b000010000000000000000, /* Rule number: 887 column_format.0 */
		0b000000000000000000100, /* Rule number: 888 column_format.1 */
		0b010000000000000000000, /* Rule number: 889 column_format.2 */
		0b000100000000000000000, /* Rule number: 890 storage_media.0 */
		0b000000000000001000000, /* Rule number: 891 storage_media.1 */
		0b000100000000000000000, /* Rule number: 892 storage_media.2 */
		0b000000000000000001000, /* Rule number: 893 now.0 */
		0b000000100000000000000, /* Rule number: 894 now_or_signed_literal.0 */
		0b000000010000000000000, /* Rule number: 895 now_or_signed_literal.1 */
		0b010000000000000000000, /* Rule number: 896 character_set.0 */
		0b000000000000010000000, /* Rule number: 897 character_set.1 */
		0b000000000000000000010, /* Rule number: 898 charset_name.0 */
		0b000000100000000000000, /* Rule number: 899 charset_name.1 */
		0b000010000000000000000, /* Rule number: 900 opt_load_data_charset.0 */
		0b000000000000000010000, /* Rule number: 901 opt_load_data_charset.1 */
		0b000010000000000000000, /* Rule number: 902 old_or_new_charset_name.0 */
		0b000000000001000000000, /* Rule number: 903 old_or_new_charset_name.1 */
		0b000000000000000000010, /* Rule number: 904 old_or_new_charset_name_or_default.0 */
		0b000000001000000000000, /* Rule number: 905 old_or_new_charset_name_or_default.1 */
		0b001000000000000000000, /* Rule number: 906 collation_name.0 */
		0b000000000000000100000, /* Rule number: 907 collation_name.1 */
		0b000000001000000000000, /* Rule number: 908 opt_collate.0 */
		0b000100000000000000000, /* Rule number: 909 opt_collate.1 */
		0b001000000000000000000, /* Rule number: 910 opt_default.0 */
		0b010000000000000000000, /* Rule number: 911 opt_default.1 */
		0b000000000100000000000, /* Rule number: 912 ascii.0 */
		0b000000000001000000000, /* Rule number: 913 ascii.1 */
		0b000000000000000000001, /* Rule number: 914 ascii.2 */
		0b000000000100000000000, /* Rule number: 915 unicode.0 */
		0b000000000001000000000, /* Rule number: 916 unicode.1 */
		0b000000010000000000000, /* Rule number: 917 unicode.2 */
		0b000000000010000000000, /* Rule number: 918 opt_charset_with_opt_binary.0 */
		0b000000000000000100000, /* Rule number: 919 opt_charset_with_opt_binary.1 */
		0b000000000000000100000, /* Rule number: 920 opt_charset_with_opt_binary.2 */
		0b000010000000000000000, /* Rule number: 921 opt_charset_with_opt_binary.3 */
		0b000010000000000000000, /* Rule number: 922 opt_charset_with_opt_binary.4 */
		0b000001000000000000000, /* Rule number: 923 opt_charset_with_opt_binary.5 */
		0b000010000000000000000, /* Rule number: 924 opt_charset_with_opt_binary.6 */
		0b000000000000000100000, /* Rule number: 925 opt_bin_mod.0 */
		0b000000000000000010000, /* Rule number: 926 opt_bin_mod.1 */
		0b000000000000010000000, /* Rule number: 927 $@36 */
		0b001000000000000000000, /* Rule number: 928 ws_num_codepoints.0 */
		0b000010000000000000000, /* Rule number: 929 opt_primary.0 */
		0b000000000000001000000, /* Rule number: 930 opt_primary.1 */
		0b000000000000010000000, /* Rule number: 931 references.0 */
		0b000000000000000001000, /* Rule number: 932 opt_ref_list.0 */
		0b000000010000000000000, /* Rule number: 933 opt_ref_list.1 */
		0b000000000000000000001, /* Rule number: 934 reference_list.0 */
		0b000000000000000000001, /* Rule number: 935 reference_list.1 */
		0b000000000000000000001, /* Rule number: 936 opt_match_clause.0 */
		0b000000000000001000000, /* Rule number: 937 opt_match_clause.1 */
		0b000000000000001000000, /* Rule number: 938 opt_match_clause.2 */
		0b001000000000000000000, /* Rule number: 939 opt_match_clause.3 */
		0b000000000000000100000, /* Rule number: 940 opt_on_update_delete.0 */
		0b000000001000000000000, /* Rule number: 941 opt_on_update_delete.1 */
		0b000000010000000000000, /* Rule number: 942 opt_on_update_delete.2 */
		0b000000100000000000000, /* Rule number: 943 opt_on_update_delete.3 */
		0b000000000000010000000, /* Rule number: 944 opt_on_update_delete.4 */
		0b000000000000010000000, /* Rule number: 945 delete_option.0 */
		0b000000000000001000000, /* Rule number: 946 delete_option.1 */
		0b000000000000000010000, /* Rule number: 947 delete_option.2 */
		0b000000100000000000000, /* Rule number: 948 delete_option.3 */
		0b000000000000000000100, /* Rule number: 949 delete_option.4 */
		0b000000100000000000000, /* Rule number: 950 constraint_key_type.0 */
		0b000010000000000000000, /* Rule number: 951 constraint_key_type.1 */
		0b000000000000000100000, /* Rule number: 952 key_or_index.0 */
		0b000000000000001000000, /* Rule number: 953 key_or_index.1 */
		0b000000010000000000000, /* Rule number: 954 opt_key_or_index.0 */
		0b000000000010000000000, /* Rule number: 955 opt_key_or_index.1 */
		0b000100000000000000000, /* Rule number: 956 keys_or_index.0 */
		0b000000000000000000010, /* Rule number: 957 keys_or_index.1 */
		0b000000000001000000000, /* Rule number: 958 keys_or_index.2 */
		0b000010000000000000000, /* Rule number: 959 opt_unique.0 */
		0b000000000000000010000, /* Rule number: 960 opt_unique.1 */
		0b001000000000000000000, /* Rule number: 961 opt_fulltext_index_options.0 */
		0b000000000010000000000, /* Rule number: 962 opt_fulltext_index_options.1 */
		0b000000001000000000000, /* Rule number: 963 fulltext_index_options.0 */
		0b000000000000010000000, /* Rule number: 964 fulltext_index_options.1 */
		0b000000001000000000000, /* Rule number: 965 fulltext_index_option.0 */
		0b001000000000000000000, /* Rule number: 966 fulltext_index_option.1 */
		0b000000000001000000000, /* Rule number: 967 opt_spatial_index_options.0 */
		0b000001000000000000000, /* Rule number: 968 opt_spatial_index_options.1 */
		0b000000100000000000000, /* Rule number: 969 spatial_index_options.0 */
		0b000000001000000000000, /* Rule number: 970 spatial_index_options.1 */
		0b100000000000000000000, /* Rule number: 971 spatial_index_option.0 */
		0b000000010000000000000, /* Rule number: 972 opt_index_options.0 */
		0b000000000000000000010, /* Rule number: 973 opt_index_options.1 */
		0b000000010000000000000, /* Rule number: 974 index_options.0 */
		0b000000000001000000000, /* Rule number: 975 index_options.1 */
		0b000001000000000000000, /* Rule number: 976 index_option.0 */
		0b000000000000000010000, /* Rule number: 977 index_option.1 */
		0b000000000000000000001, /* Rule number: 978 common_index_option.0 */
		0b010000000000000000000, /* Rule number: 979 common_index_option.1 */
		0b000000000010000000000, /* Rule number: 980 common_index_option.2 */
		0b000000000000000000010, /* Rule number: 981 common_index_option.3 */
		0b000000000000000000001, /* Rule number: 982 common_index_option.4 */
		0b000000000000001000000, /* Rule number: 983 opt_index_name_and_type.0 */
		0b000100000000000000000, /* Rule number: 984 opt_index_name_and_type.1 */
		0b000000000100000000000, /* Rule number: 985 opt_index_name_and_type.2 */
		0b000000100000000000000, /* Rule number: 986 opt_index_type_clause.0 */
		0b000000000100000000000, /* Rule number: 987 opt_index_type_clause.1 */
		0b001000000000000000000, /* Rule number: 988 index_type_clause.0 */
		0b000000010000000000000, /* Rule number: 989 index_type_clause.1 */
		0b000000000001000000000, /* Rule number: 990 visibility.0 */
		0b000100000000000000000, /* Rule number: 991 visibility.1 */
		0b000000000000001000000, /* Rule number: 992 index_type.0 */
		0b000000000000000000100, /* Rule number: 993 index_type.1 */
		0b100000000000000000000, /* Rule number: 994 index_type.2 */
		0b000000000000000100000, /* Rule number: 995 key_list.0 */
		0b000000000000100000000, /* Rule number: 996 key_list.1 */
		0b000000000010000000000, /* Rule number: 997 key_part.0 */
		0b000010000000000000000, /* Rule number: 998 key_part.1 */
		0b000000000000000100000, /* Rule number: 999 key_list_with_expression.0 */
		0b000000000000000100000, /* Rule number: 1000 key_list_with_expression.1 */
		0b000000000001000000000, /* Rule number: 1001 key_part_with_expression.0 */
		0b000000000100000000000, /* Rule number: 1002 key_part_with_expression.1 */
		0b000100000000000000000, /* Rule number: 1003 opt_ident.0 */
		0b000000000000000010000, /* Rule number: 1004 opt_ident.1 */
		0b000000000000000001000, /* Rule number: 1005 string_list.0 */
		0b100000000000000000000, /* Rule number: 1006 string_list.1 */
		0b000000000000100000000, /* Rule number: 1007 alter_table_stmt.0 */
		0b000000000000001000000, /* Rule number: 1008 alter_table_stmt.1 */
		0b000000000001000000000, /* Rule number: 1009 $@37 */
		0b000100000000000000000, /* Rule number: 1010 alter_database_stmt.0 */
		0b000000000000000000100, /* Rule number: 1011 $@38 */
		0b000000000000000010000, /* Rule number: 1012 alter_procedure_stmt.0 */
		0b000000000000010000000, /* Rule number: 1013 $@39 */
		0b000000000000000000010, /* Rule number: 1014 alter_function_stmt.0 */
		0b001000000000000000000, /* Rule number: 1015 $@40 */
		0b000000000000000000001, /* Rule number: 1016 $@41 */
		0b000000000010000000000, /* Rule number: 1017 alter_view_stmt.0 */
		0b000000000000000001000, /* Rule number: 1018 alter_view_stmt.1 */
		0b000000010000000000000, /* Rule number: 1019 $@42 */
		0b000000100000000000000, /* Rule number: 1020 alter_event_stmt.0 */
		0b000000000000000100000, /* Rule number: 1021 alter_logfile_stmt.0 */
		0b000100000000000000000, /* Rule number: 1022 alter_tablespace_stmt.0 */
		0b000000000000010000000, /* Rule number: 1023 alter_tablespace_stmt.1 */
		0b000000000100000000000, /* Rule number: 1024 alter_tablespace_stmt.2 */
		0b000000000000001000000, /* Rule number: 1025 alter_tablespace_stmt.3 */
		0b000000000000010000000, /* Rule number: 1026 alter_undo_tablespace_stmt.0 */
		0b000000000100000000000, /* Rule number: 1027 alter_server_stmt.0 */
		0b000000001000000000000, /* Rule number: 1028 alter_user_stmt.0 */
		0b000000001000000000000, /* Rule number: 1029 alter_user_stmt.1 */
		0b000000100000000000000, /* Rule number: 1030 alter_user_stmt.2 */
		0b000000000000000000001, /* Rule number: 1031 alter_user_stmt.3 */
		0b000000010000000000000, /* Rule number: 1032 alter_user_stmt.4 */
		0b000000000000000000001, /* Rule number: 1033 alter_user_stmt.5 */
		0b000000001000000000000, /* Rule number: 1034 alter_user_stmt.6 */
		0b000000000000000010000, /* Rule number: 1035 alter_user_stmt.7 */
		0b100000000000000000000, /* Rule number: 1036 alter_user_stmt.8 */
		0b000100000000000000000, /* Rule number: 1037 opt_replace_password.0 */
		0b000001000000000000000, /* Rule number: 1038 opt_replace_password.1 */
		0b010000000000000000000, /* Rule number: 1039 alter_resource_group_stmt.0 */
		0b000000001000000000000, /* Rule number: 1040 alter_user_command.0 */
		0b000000000000010000000, /* Rule number: 1041 opt_user_attribute.0 */
		0b000000000000000100000, /* Rule number: 1042 opt_user_attribute.1 */
		0b000000000000001000000, /* Rule number: 1043 opt_user_attribute.2 */
		0b000000000000000010000, /* Rule number: 1044 opt_account_lock_password_expire_options.0 */
		0b000000010000000000000, /* Rule number: 1045 opt_account_lock_password_expire_options.1 */
		0b000000000001000000000, /* Rule number: 1046 opt_account_lock_password_expire_option_list.0 */
		0b000000000000000010000, /* Rule number: 1047 opt_account_lock_password_expire_option_list.1 */
		0b000000100000000000000, /* Rule number: 1048 opt_account_lock_password_expire_option.0 */
		0b010000000000000000000, /* Rule number: 1049 opt_account_lock_password_expire_option.1 */
		0b000000000000100000000, /* Rule number: 1050 opt_account_lock_password_expire_option.2 */
		0b000000001000000000000, /* Rule number: 1051 opt_account_lock_password_expire_option.3 */
		0b000000000001000000000, /* Rule number: 1052 opt_account_lock_password_expire_option.4 */
		0b010000000000000000000, /* Rule number: 1053 opt_account_lock_password_expire_option.5 */
		0b000000000100000000000, /* Rule number: 1054 opt_account_lock_password_expire_option.6 */
		0b010000000000000000000, /* Rule number: 1055 opt_account_lock_password_expire_option.7 */
		0b010000000000000000000, /* Rule number: 1056 opt_account_lock_password_expire_option.8 */
		0b000000000000100000000, /* Rule number: 1057 opt_account_lock_password_expire_option.9 */
		0b000000100000000000000, /* Rule number: 1058 opt_account_lock_password_expire_option.10 */
		0b000000000000000100000, /* Rule number: 1059 opt_account_lock_password_expire_option.11 */
		0b000100000000000000000, /* Rule number: 1060 opt_account_lock_password_expire_option.12 */
		0b000000000010000000000, /* Rule number: 1061 opt_account_lock_password_expire_option.13 */
		0b000000000000010000000, /* Rule number: 1062 opt_account_lock_password_expire_option.14 */
		0b000000000000000000010, /* Rule number: 1063 opt_account_lock_password_expire_option.15 */
		0b000000000000000001000, /* Rule number: 1064 connect_options.0 */
		0b000000000000000010000, /* Rule number: 1065 connect_options.1 */
		0b000000100000000000000, /* Rule number: 1066 connect_option_list.0 */
		0b100000000000000000000, /* Rule number: 1067 connect_option_list.1 */
		0b000000100000000000000, /* Rule number: 1068 connect_option.0 */
		0b000000000000000010000, /* Rule number: 1069 connect_option.1 */
		0b000000000000010000000, /* Rule number: 1070 connect_option.2 */
		0b000000000000001000000, /* Rule number: 1071 connect_option.3 */
		0b010000000000000000000, /* Rule number: 1072 user_func.0 */
		0b000000000000000001000, /* Rule number: 1073 ev_alter_on_schedule_completion.0 */
		0b001000000000000000000, /* Rule number: 1074 ev_alter_on_schedule_completion.1 */
		0b010000000000000000000, /* Rule number: 1075 ev_alter_on_schedule_completion.2 */
		0b000000000000000000010, /* Rule number: 1076 ev_alter_on_schedule_completion.3 */
		0b100000000000000000000, /* Rule number: 1077 opt_ev_rename_to.0 */
		0b000000000000000000010, /* Rule number: 1078 opt_ev_rename_to.1 */
		0b000000000010000000000, /* Rule number: 1079 opt_ev_sql_stmt.0 */
		0b000001000000000000000, /* Rule number: 1080 opt_ev_sql_stmt.1 */
		0b000000000000000000001, /* Rule number: 1081 ident_or_empty.0 */
		0b000000000000000000010, /* Rule number: 1082 ident_or_empty.1 */
		0b000000001000000000000, /* Rule number: 1083 opt_alter_table_actions.0 */
		0b010000000000000000000, /* Rule number: 1084 opt_alter_table_actions.1 */
		0b000000000000010000000, /* Rule number: 1085 standalone_alter_table_action.0 */
		0b000000000000000100000, /* Rule number: 1086 standalone_alter_table_action.1 */
		0b000000000000000100000, /* Rule number: 1087 alter_table_partition_options.0 */
		0b000000000000000001000, /* Rule number: 1088 alter_table_partition_options.1 */
		0b000000000100000000000, /* Rule number: 1089 opt_alter_command_list.0 */
		0b010000000000000000000, /* Rule number: 1090 opt_alter_command_list.1 */
		0b001000000000000000000, /* Rule number: 1091 opt_alter_command_list.2 */
		0b000000100000000000000, /* Rule number: 1092 opt_alter_command_list.3 */
		0b100000000000000000000, /* Rule number: 1093 standalone_alter_commands.0 */
		0b100000000000000000000, /* Rule number: 1094 standalone_alter_commands.1 */
		0b000000001000000000000, /* Rule number: 1095 standalone_alter_commands.2 */
		0b000000100000000000000, /* Rule number: 1096 standalone_alter_commands.3 */
		0b000000000000000010000, /* Rule number: 1097 standalone_alter_commands.4 */
		0b100000000000000000000, /* Rule number: 1098 standalone_alter_commands.5 */
		0b000000000000000001000, /* Rule number: 1099 standalone_alter_commands.6 */
		0b010000000000000000000, /* Rule number: 1100 standalone_alter_commands.7 */
		0b000000010000000000000, /* Rule number: 1101 standalone_alter_commands.8 */
		0b000010000000000000000, /* Rule number: 1102 standalone_alter_commands.9 */
		0b000001000000000000000, /* Rule number: 1103 standalone_alter_commands.10 */
		0b000000000000000100000, /* Rule number: 1104 standalone_alter_commands.11 */
		0b000001000000000000000, /* Rule number: 1105 standalone_alter_commands.12 */
		0b000000000000000001000, /* Rule number: 1106 standalone_alter_commands.13 */
		0b000000000000000000001, /* Rule number: 1107 standalone_alter_commands.14 */
		0b010000000000000000000, /* Rule number: 1108 standalone_alter_commands.15 */
		0b000001000000000000000, /* Rule number: 1109 standalone_alter_commands.16 */
		0b100000000000000000000, /* Rule number: 1110 standalone_alter_commands.17 */
		0b000000010000000000000, /* Rule number: 1111 standalone_alter_commands.18 */
		0b000000000000000010000, /* Rule number: 1112 standalone_alter_commands.19 */
		0b000000000000000010000, /* Rule number: 1113 opt_with_validation.0 */
		0b000000000000100000000, /* Rule number: 1114 opt_with_validation.1 */
		0b000100000000000000000, /* Rule number: 1115 with_validation.0 */
		0b000000000000000000001, /* Rule number: 1116 with_validation.1 */
		0b000010000000000000000, /* Rule number: 1117 all_or_alt_part_name_list.0 */
		0b000000100000000000000, /* Rule number: 1118 all_or_alt_part_name_list.1 */
		0b000001000000000000000, /* Rule number: 1119 alter_list.0 */
		0b000000000000001000000, /* Rule number: 1120 alter_list.1 */
		0b000000000000000000001, /* Rule number: 1121 alter_list.2 */
		0b000000100000000000000, /* Rule number: 1122 alter_list.3 */
		0b000000010000000000000, /* Rule number: 1123 alter_list.4 */
		0b000000100000000000000, /* Rule number: 1124 alter_commands_modifier_list.0 */
		0b000000000000000100000, /* Rule number: 1125 alter_commands_modifier_list.1 */
		0b000001000000000000000, /* Rule number: 1126 alter_list_item.0 */
		0b000000000000000000001, /* Rule number: 1127 alter_list_item.1 */
		0b010000000000000000000, /* Rule number: 1128 alter_list_item.2 */
		0b000000000000001000000, /* Rule number: 1129 alter_list_item.3 */
		0b000000000001000000000, /* Rule number: 1130 alter_list_item.4 */
		0b000000000000000010000, /* Rule number: 1131 alter_list_item.5 */
		0b000000000000000100000, /* Rule number: 1132 alter_list_item.6 */
		0b000000000000010000000, /* Rule number: 1133 alter_list_item.7 */
		0b000000000001000000000, /* Rule number: 1134 alter_list_item.8 */
		0b000000000000000100000, /* Rule number: 1135 alter_list_item.9 */
		0b000000000000000100000, /* Rule number: 1136 alter_list_item.10 */
		0b010000000000000000000, /* Rule number: 1137 alter_list_item.11 */
		0b000000010000000000000, /* Rule number: 1138 alter_list_item.12 */
		0b010000000000000000000, /* Rule number: 1139 alter_list_item.13 */
		0b000000000000000100000, /* Rule number: 1140 alter_list_item.14 */
		0b000000000000001000000, /* Rule number: 1141 alter_list_item.15 */
		0b000000000000000000001, /* Rule number: 1142 alter_list_item.16 */
		0b000000000000001000000, /* Rule number: 1143 alter_list_item.17 */
		0b000100000000000000000, /* Rule number: 1144 alter_list_item.18 */
		0b000000000000000010000, /* Rule number: 1145 alter_list_item.19 */
		0b000000001000000000000, /* Rule number: 1146 alter_list_item.20 */
		0b000000000000100000000, /* Rule number: 1147 alter_list_item.21 */
		0b000000000000000010000, /* Rule number: 1148 alter_list_item.22 */
		0b000000010000000000000, /* Rule number: 1149 alter_list_item.23 */
		0b000000000000000010000, /* Rule number: 1150 alter_list_item.24 */
		0b000001000000000000000, /* Rule number: 1151 alter_list_item.25 */
		0b000000010000000000000, /* Rule number: 1152 alter_list_item.26 */
		0b000000000000000010000, /* Rule number: 1153 alter_commands_modifier.0 */
		0b000000000000000010000, /* Rule number: 1154 alter_commands_modifier.1 */
		0b000000000000010000000, /* Rule number: 1155 alter_commands_modifier.2 */
		0b000000000001000000000, /* Rule number: 1156 opt_index_lock_and_algorithm.0 */
		0b000000000000000000100, /* Rule number: 1157 opt_index_lock_and_algorithm.1 */
		0b000000000100000000000, /* Rule number: 1158 opt_index_lock_and_algorithm.2 */
		0b000000000000100000000, /* Rule number: 1159 opt_index_lock_and_algorithm.3 */
		0b000000000100000000000, /* Rule number: 1160 opt_index_lock_and_algorithm.4 */
		0b001000000000000000000, /* Rule number: 1161 alter_algorithm_option.0 */
		0b010000000000000000000, /* Rule number: 1162 alter_algorithm_option_value.0 */
		0b000010000000000000000, /* Rule number: 1163 alter_algorithm_option_value.1 */
		0b001000000000000000000, /* Rule number: 1164 alter_lock_option.0 */
		0b000001000000000000000, /* Rule number: 1165 alter_lock_option_value.0 */
		0b001000000000000000000, /* Rule number: 1166 alter_lock_option_value.1 */
		0b000000000000000001000, /* Rule number: 1167 opt_column.0 */
		0b000000001000000000000, /* Rule number: 1168 opt_column.1 */
		0b001000000000000000000, /* Rule number: 1169 opt_ignore.0 */
		0b000000000000000001000, /* Rule number: 1170 opt_ignore.1 */
		0b000000000000001000000, /* Rule number: 1171 opt_restrict.0 */
		0b000000100000000000000, /* Rule number: 1172 opt_restrict.1 */
		0b000000000000000000001, /* Rule number: 1173 opt_restrict.2 */
		0b000000000010000000000, /* Rule number: 1174 opt_place.0 */
		0b000000010000000000000, /* Rule number: 1175 opt_place.1 */
		0b000000000000000000010, /* Rule number: 1176 opt_place.2 */
		0b001000000000000000000, /* Rule number: 1177 opt_to.0 */
		0b000000000100000000000, /* Rule number: 1178 opt_to.1 */
		0b000001000000000000000, /* Rule number: 1179 opt_to.2 */
		0b000000000001000000000, /* Rule number: 1180 opt_to.3 */
		0b000000000000000100000, /* Rule number: 1181 group_replication.0 */
		0b000000001000000000000, /* Rule number: 1182 group_replication.1 */
		0b001000000000000000000, /* Rule number: 1183 group_replication_start.0 */
		0b000100000000000000000, /* Rule number: 1184 opt_group_replication_start_options.0 */
		0b000000000100000000000, /* Rule number: 1185 opt_group_replication_start_options.1 */
		0b000100000000000000000, /* Rule number: 1186 group_replication_start_options.0 */
		0b000000001000000000000, /* Rule number: 1187 group_replication_start_options.1 */
		0b000000100000000000000, /* Rule number: 1188 group_replication_start_option.0 */
		0b000001000000000000000, /* Rule number: 1189 group_replication_start_option.1 */
		0b100000000000000000000, /* Rule number: 1190 group_replication_start_option.2 */
		0b000000000001000000000, /* Rule number: 1191 group_replication_user.0 */
		0b000000000000010000000, /* Rule number: 1192 group_replication_password.0 */
		0b000000000010000000000, /* Rule number: 1193 group_replication_plugin_auth.0 */
		0b000010000000000000000, /* Rule number: 1194 stop_replica_stmt.0 */
		0b000000000000000010000, /* Rule number: 1195 $@43 */
		0b001000000000000000000, /* Rule number: 1196 $@44 */
		0b000001000000000000000, /* Rule number: 1197 start_replica_stmt.0 */
		0b000000000000000100000, /* Rule number: 1198 start.0 */
		0b000000000000000000001, /* Rule number: 1199 opt_start_transaction_option_list.0 */
		0b000000000000000000001, /* Rule number: 1200 opt_start_transaction_option_list.1 */
		0b000000000000000010000, /* Rule number: 1201 start_transaction_option_list.0 */
		0b000000000000000000100, /* Rule number: 1202 start_transaction_option_list.1 */
		0b010000000000000000000, /* Rule number: 1203 start_transaction_option.0 */
		0b000000000000001000000, /* Rule number: 1204 start_transaction_option.1 */
		0b000001000000000000000, /* Rule number: 1205 start_transaction_option.2 */
		0b000000000100000000000, /* Rule number: 1206 opt_user_option.0 */
		0b100000000000000000000, /* Rule number: 1207 opt_user_option.1 */
		0b000010000000000000000, /* Rule number: 1208 opt_password_option.0 */
		0b000000000000000000001, /* Rule number: 1209 opt_password_option.1 */
		0b000000000000000010000, /* Rule number: 1210 opt_default_auth_option.0 */
		0b000000000000100000000, /* Rule number: 1211 opt_default_auth_option.1 */
		0b000000000000001000000, /* Rule number: 1212 opt_plugin_dir_option.0 */
		0b100000000000000000000, /* Rule number: 1213 opt_plugin_dir_option.1 */
		0b000000000010000000000, /* Rule number: 1214 opt_replica_thread_option_list.0 */
		0b000000000000000001000, /* Rule number: 1215 opt_replica_thread_option_list.1 */
		0b000000000000000000100, /* Rule number: 1216 replica_thread_option_list.0 */
		0b000000000000000000001, /* Rule number: 1217 replica_thread_option_list.1 */
		0b000000000010000000000, /* Rule number: 1218 replica_thread_option.0 */
		0b000000000000000001000, /* Rule number: 1219 replica_thread_option.1 */
		0b000000001000000000000, /* Rule number: 1220 opt_replica_until.0 */
		0b000000100000000000000, /* Rule number: 1221 opt_replica_until.1 */
		0b000000001000000000000, /* Rule number: 1222 replica_until.0 */
		0b000000000010000000000, /* Rule number: 1223 replica_until.1 */
		0b000100000000000000000, /* Rule number: 1224 replica_until.2 */
		0b001000000000000000000, /* Rule number: 1225 replica_until.3 */
		0b100000000000000000000, /* Rule number: 1226 replica_until.4 */
		0b000000000000000001000, /* Rule number: 1227 checksum.0 */
		0b000001000000000000000, /* Rule number: 1228 opt_checksum_type.0 */
		0b000000100000000000000, /* Rule number: 1229 opt_checksum_type.1 */
		0b000010000000000000000, /* Rule number: 1230 opt_checksum_type.2 */
		0b010000000000000000000, /* Rule number: 1231 repair_table_stmt.0 */
		0b000001000000000000000, /* Rule number: 1232 opt_mi_repair_types.0 */
		0b000000000000000000010, /* Rule number: 1233 opt_mi_repair_types.1 */
		0b000000001000000000000, /* Rule number: 1234 mi_repair_types.0 */
		0b001000000000000000000, /* Rule number: 1235 mi_repair_types.1 */
		0b000001000000000000000, /* Rule number: 1236 mi_repair_type.0 */
		0b000000000001000000000, /* Rule number: 1237 mi_repair_type.1 */
		0b000000000000000100000, /* Rule number: 1238 mi_repair_type.2 */
		0b000000100000000000000, /* Rule number: 1239 analyze_table_stmt.0 */
		0b010000000000000000000, /* Rule number: 1240 opt_histogram_auto_update.0 */
		0b000000000000001000000, /* Rule number: 1241 opt_histogram_auto_update.1 */
		0b000000000000000000001, /* Rule number: 1242 opt_histogram_auto_update.2 */
		0b000100000000000000000, /* Rule number: 1243 opt_histogram_num_buckets.0 */
		0b000010000000000000000, /* Rule number: 1244 opt_histogram_num_buckets.1 */
		0b000000100000000000000, /* Rule number: 1245 opt_histogram_update_param.0 */
		0b000000000000000100000, /* Rule number: 1246 opt_histogram_update_param.1 */
		0b000000000000000010000, /* Rule number: 1247 opt_histogram.0 */
		0b000010000000000000000, /* Rule number: 1248 opt_histogram.1 */
		0b000000010000000000000, /* Rule number: 1249 opt_histogram.2 */
		0b000000000000000100000, /* Rule number: 1250 binlog_base64_event.0 */
		0b000000100000000000000, /* Rule number: 1251 check_table_stmt.0 */
		0b000000000000010000000, /* Rule number: 1252 opt_mi_check_types.0 */
		0b000000000001000000000, /* Rule number: 1253 opt_mi_check_types.1 */
		0b000000100000000000000, /* Rule number: 1254 mi_check_types.0 */
		0b000000000001000000000, /* Rule number: 1255 mi_check_types.1 */
		0b000001000000000000000, /* Rule number: 1256 mi_check_type.0 */
		0b000000000000000010000, /* Rule number: 1257 mi_check_type.1 */
		0b000000000010000000000, /* Rule number: 1258 mi_check_type.2 */
		0b000000000000000000010, /* Rule number: 1259 mi_check_type.3 */
		0b000000000000000000100, /* Rule number: 1260 mi_check_type.4 */
		0b000000000010000000000, /* Rule number: 1261 mi_check_type.5 */
		0b000010000000000000000, /* Rule number: 1262 optimize_table_stmt.0 */
		0b000000000000000001000, /* Rule number: 1263 opt_no_write_to_binlog.0 */
		0b000000000000000000001, /* Rule number: 1264 opt_no_write_to_binlog.1 */
		0b000000000010000000000, /* Rule number: 1265 opt_no_write_to_binlog.2 */
		0b000000000000000010000, /* Rule number: 1266 $@45 */
		0b000000000000000010000, /* Rule number: 1267 rename.0 */
		0b001000000000000000000, /* Rule number: 1268 rename.1 */
		0b000000000000000010000, /* Rule number: 1269 rename_list.0 */
		0b000000000000100000000, /* Rule number: 1270 rename_list.1 */
		0b000100000000000000000, /* Rule number: 1271 table_to_table_list.0 */
		0b000000000000000000100, /* Rule number: 1272 table_to_table_list.1 */
		0b000000000000000000001, /* Rule number: 1273 table_to_table.0 */
		0b000001000000000000000, /* Rule number: 1274 keycache_stmt.0 */
		0b000100000000000000000, /* Rule number: 1275 keycache_stmt.1 */
		0b000000001000000000000, /* Rule number: 1276 keycache_list.0 */
		0b010000000000000000000, /* Rule number: 1277 keycache_list.1 */
		0b000000000100000000000, /* Rule number: 1278 assign_to_keycache.0 */
		0b000000000000001000000, /* Rule number: 1279 key_cache_name.0 */
		0b000010000000000000000, /* Rule number: 1280 key_cache_name.1 */
		0b000100000000000000000, /* Rule number: 1281 preload_stmt.0 */
		0b000000000000000010000, /* Rule number: 1282 preload_stmt.1 */
		0b000010000000000000000, /* Rule number: 1283 preload_list.0 */
		0b000000000000000001000, /* Rule number: 1284 preload_list.1 */
		0b000000010000000000000, /* Rule number: 1285 preload_keys.0 */
		0b000000000100000000000, /* Rule number: 1286 adm_partition.0 */
		0b000000000000000000100, /* Rule number: 1287 opt_cache_key_list.0 */
		0b000000000010000000000, /* Rule number: 1288 opt_cache_key_list.1 */
		0b000000000000000000001, /* Rule number: 1289 opt_ignore_leaves.0 */
		0b000000000000000000010, /* Rule number: 1290 opt_ignore_leaves.1 */
		0b000010000000000000000, /* Rule number: 1291 select_stmt.0 */
		0b000001000000000000000, /* Rule number: 1292 select_stmt.1 */
		0b000000000100000000000, /* Rule number: 1293 select_stmt.2 */
		0b000000000000000100000, /* Rule number: 1294 select_stmt_with_into.0 */
		0b000000000000000100000, /* Rule number: 1295 select_stmt_with_into.1 */
		0b000000000000001000000, /* Rule number: 1296 select_stmt_with_into.2 */
		0b010000000000000000000, /* Rule number: 1297 select_stmt_with_into.3 */
		0b000000000000000000010, /* Rule number: 1298 query_expression.0 */
		0b000000000100000000000, /* Rule number: 1299 query_expression.1 */
		0b000000000000001000000, /* Rule number: 1300 query_expression_body.0 */
		0b100000000000000000000, /* Rule number: 1301 query_expression_body.1 */
		0b000000000000000001000, /* Rule number: 1302 query_expression_body.2 */
		0b000000000000000000100, /* Rule number: 1303 query_expression_body.3 */
		0b000100000000000000000, /* Rule number: 1304 query_expression_body.4 */
		0b100000000000000000000, /* Rule number: 1305 query_expression_parens.0 */
		0b000100000000000000000, /* Rule number: 1306 query_expression_parens.1 */
		0b000000000000000001000, /* Rule number: 1307 query_primary.0 */
		0b100000000000000000000, /* Rule number: 1308 query_primary.1 */
		0b000000000000000100000, /* Rule number: 1309 query_primary.2 */
		0b001000000000000000000, /* Rule number: 1310 query_specification.0 */
		0b000000000010000000000, /* Rule number: 1311 query_specification.1 */
		0b001000000000000000000, /* Rule number: 1312 opt_from_clause.0 */
		0b000000000000000000001, /* Rule number: 1313 opt_from_clause.1 */
		0b000000000000000000001, /* Rule number: 1314 from_clause.0 */
		0b000100000000000000000, /* Rule number: 1315 from_tables.0 */
		0b000000000000100000000, /* Rule number: 1316 from_tables.1 */
		0b000000000000010000000, /* Rule number: 1317 table_reference_list.0 */
		0b100000000000000000000, /* Rule number: 1318 table_reference_list.1 */
		0b000000000000000100000, /* Rule number: 1319 table_value_constructor.0 */
		0b000000000001000000000, /* Rule number: 1320 explicit_table.0 */
		0b010000000000000000000, /* Rule number: 1321 select_options.0 */
		0b100000000000000000000, /* Rule number: 1322 select_options.1 */
		0b010000000000000000000, /* Rule number: 1323 select_option_list.0 */
		0b010000000000000000000, /* Rule number: 1324 select_option_list.1 */
		0b000000000100000000000, /* Rule number: 1325 select_option.0 */
		0b000010000000000000000, /* Rule number: 1326 select_option.1 */
		0b000000000000001000000, /* Rule number: 1327 locking_clause_list.0 */
		0b000000001000000000000, /* Rule number: 1328 locking_clause_list.1 */
		0b000000000000000000010, /* Rule number: 1329 locking_clause.0 */
		0b000100000000000000000, /* Rule number: 1330 locking_clause.1 */
		0b000000000100000000000, /* Rule number: 1331 locking_clause.2 */
		0b000000000001000000000, /* Rule number: 1332 lock_strength.0 */
		0b010000000000000000000, /* Rule number: 1333 lock_strength.1 */
		0b000000000000000100000, /* Rule number: 1334 table_locking_list.0 */
		0b000000000000001000000, /* Rule number: 1335 opt_locked_row_action.0 */
		0b000000000000010000000, /* Rule number: 1336 opt_locked_row_action.1 */
		0b000000000010000000000, /* Rule number: 1337 locked_row_action.0 */
		0b000000000000000000100, /* Rule number: 1338 locked_row_action.1 */
		0b000000000010000000000, /* Rule number: 1339 select_item_list.0 */
		0b000000000000000000001, /* Rule number: 1340 select_item_list.1 */
		0b000100000000000000000, /* Rule number: 1341 select_item_list.2 */
		0b000000000000000000001, /* Rule number: 1342 select_item.0 */
		0b000000001000000000000, /* Rule number: 1343 select_item.1 */
		0b000000010000000000000, /* Rule number: 1344 select_alias.0 */
		0b100000000000000000000, /* Rule number: 1345 select_alias.1 */
		0b000000010000000000000, /* Rule number: 1346 select_alias.2 */
		0b000000000000010000000, /* Rule number: 1347 select_alias.3 */
		0b000000010000000000000, /* Rule number: 1348 select_alias.4 */
		0b000000000000001000000, /* Rule number: 1349 optional_braces.0 */
		0b000000000000000010000, /* Rule number: 1350 optional_braces.1 */
		0b000000000000000001000, /* Rule number: 1351 expr.0 */
		0b000000000001000000000, /* Rule number: 1352 expr.1 */
		0b001000000000000000000, /* Rule number: 1353 expr.2 */
		0b000000000000000100000, /* Rule number: 1354 expr.3 */
		0b000000100000000000000, /* Rule number: 1355 expr.4 */
		0b000001000000000000000, /* Rule number: 1356 expr.5 */
		0b000000000100000000000, /* Rule number: 1357 expr.6 */
		0b000000000010000000000, /* Rule number: 1358 expr.7 */
		0b000000000000010000000, /* Rule number: 1359 expr.8 */
		0b010000000000000000000, /* Rule number: 1360 expr.9 */
		0b000100000000000000000, /* Rule number: 1361 expr.10 */
		0b000001000000000000000, /* Rule number: 1362 bool_pri.0 */
		0b000010000000000000000, /* Rule number: 1363 bool_pri.1 */
		0b000000000001000000000, /* Rule number: 1364 bool_pri.2 */
		0b000000000000000000100, /* Rule number: 1365 bool_pri.3 */
		0b000000000000000010000, /* Rule number: 1366 bool_pri.4 */
		0b000000000000000000100, /* Rule number: 1367 predicate.0 */
		0b000000000100000000000, /* Rule number: 1368 predicate.1 */
		0b000010000000000000000, /* Rule number: 1369 predicate.2 */
		0b000000000000000010000, /* Rule number: 1370 predicate.3 */
		0b001000000000000000000, /* Rule number: 1371 predicate.4 */
		0b000000010000000000000, /* Rule number: 1372 predicate.5 */
		0b000000000100000000000, /* Rule number: 1373 predicate.6 */
		0b000000000000000010000, /* Rule number: 1374 predicate.7 */
		0b010000000000000000000, /* Rule number: 1375 predicate.8 */
		0b000000000000100000000, /* Rule number: 1376 predicate.9 */
		0b001000000000000000000, /* Rule number: 1377 predicate.10 */
		0b000001000000000000000, /* Rule number: 1378 predicate.11 */
		0b000000000000001000000, /* Rule number: 1379 predicate.12 */
		0b000000100000000000000, /* Rule number: 1380 predicate.13 */
		0b000000000001000000000, /* Rule number: 1381 predicate.14 */
		0b000100000000000000000, /* Rule number: 1382 predicate.15 */
		0b010000000000000000000, /* Rule number: 1383 predicate.16 */
		0b000000000000000000001, /* Rule number: 1384 opt_of.0 */
		0b000000000000000001000, /* Rule number: 1385 opt_of.1 */
		0b000000000000000000100, /* Rule number: 1386 bit_expr.0 */
		0b000000000000001000000, /* Rule number: 1387 bit_expr.1 */
		0b000000000000000000001, /* Rule number: 1388 bit_expr.2 */
		0b000000000000000001000, /* Rule number: 1389 bit_expr.3 */
		0b000000000000000001000, /* Rule number: 1390 bit_expr.4 */
		0b100000000000000000000, /* Rule number: 1391 bit_expr.5 */
		0b000000000000000000010, /* Rule number: 1392 bit_expr.6 */
		0b010000000000000000000, /* Rule number: 1393 bit_expr.7 */
		0b000010000000000000000, /* Rule number: 1394 bit_expr.8 */
		0b000000000000000010000, /* Rule number: 1395 bit_expr.9 */
		0b000000000000000000001, /* Rule number: 1396 bit_expr.10 */
		0b000000000000000000001, /* Rule number: 1397 bit_expr.11 */
		0b000000000000001000000, /* Rule number: 1398 bit_expr.12 */
		0b000000000000010000000, /* Rule number: 1399 bit_expr.13 */
		0b100000000000000000000, /* Rule number: 1400 bit_expr.14 */
		0b000000000001000000000, /* Rule number: 1401 or.0 */
		0b000000000000000001000, /* Rule number: 1402 or.1 */
		0b010000000000000000000, /* Rule number: 1403 and.0 */
		0b000001000000000000000, /* Rule number: 1404 and.1 */
		0b000000001000000000000, /* Rule number: 1405 not.0 */
		0b000000000100000000000, /* Rule number: 1406 not.1 */
		0b000000000000000000100, /* Rule number: 1407 not2.0 */
		0b000100000000000000000, /* Rule number: 1408 not2.1 */
		0b000000000010000000000, /* Rule number: 1409 comp_op.0 */
		0b100000000000000000000, /* Rule number: 1410 comp_op.1 */
		0b000001000000000000000, /* Rule number: 1411 comp_op.2 */
		0b000000000010000000000, /* Rule number: 1412 comp_op.3 */
		0b000010000000000000000, /* Rule number: 1413 comp_op.4 */
		0b100000000000000000000, /* Rule number: 1414 comp_op.5 */
		0b000000000000000000100, /* Rule number: 1415 comp_op.6 */
		0b000000000000000000100, /* Rule number: 1416 all_or_any.0 */
		0b000000000000000000010, /* Rule number: 1417 all_or_any.1 */
		0b000000100000000000000, /* Rule number: 1418 simple_expr.0 */
		0b100000000000000000000, /* Rule number: 1419 simple_expr.1 */
		0b100000000000000000000, /* Rule number: 1420 simple_expr.2 */
		0b000000000100000000000, /* Rule number: 1421 simple_expr.3 */
		0b000000000000000010000, /* Rule number: 1422 simple_expr.4 */
		0b000001000000000000000, /* Rule number: 1423 simple_expr.5 */
		0b000000000000100000000, /* Rule number: 1424 simple_expr.6 */
		0b000000000000000000010, /* Rule number: 1425 simple_expr.7 */
		0b001000000000000000000, /* Rule number: 1426 simple_expr.8 */
		0b000000000100000000000, /* Rule number: 1427 simple_expr.9 */
		0b000000000000000000010, /* Rule number: 1428 simple_expr.10 */
		0b000000000000000000001, /* Rule number: 1429 simple_expr.11 */
		0b000001000000000000000, /* Rule number: 1430 simple_expr.12 */
		0b000000000000000010000, /* Rule number: 1431 simple_expr.13 */
		0b000000000001000000000, /* Rule number: 1432 simple_expr.14 */
		0b000001000000000000000, /* Rule number: 1433 simple_expr.15 */
		0b000000100000000000000, /* Rule number: 1434 simple_expr.16 */
		0b000001000000000000000, /* Rule number: 1435 simple_expr.17 */
		0b000000000000010000000, /* Rule number: 1436 simple_expr.18 */
		0b000100000000000000000, /* Rule number: 1437 simple_expr.19 */
		0b000000000000000000010, /* Rule number: 1438 simple_expr.20 */
		0b000000000000100000000, /* Rule number: 1439 simple_expr.21 */
		0b000000000100000000000, /* Rule number: 1440 simple_expr.22 */
		0b000000000010000000000, /* Rule number: 1441 simple_expr.23 */
		0b000000000001000000000, /* Rule number: 1442 simple_expr.24 */
		0b000000100000000000000, /* Rule number: 1443 simple_expr.25 */
		0b000010000000000000000, /* Rule number: 1444 simple_expr.26 */
		0b000000010000000000000, /* Rule number: 1445 simple_expr.27 */
		0b000000000000100000000, /* Rule number: 1446 simple_expr.28 */
		0b001000000000000000000, /* Rule number: 1447 simple_expr.29 */
		0b000000010000000000000, /* Rule number: 1448 simple_expr.30 */
		0b000000000000100000000, /* Rule number: 1449 simple_expr.31 */
		0b000000000000000010000, /* Rule number: 1450 simple_expr.32 */
		0b000000000000000000100, /* Rule number: 1451 simple_expr.33 */
		0b000000001000000000000, /* Rule number: 1452 simple_expr.34 */
		0b000000000000000000100, /* Rule number: 1453 simple_expr.35 */
		0b001000000000000000000, /* Rule number: 1454 opt_array_cast.0 */
		0b000000000000000010000, /* Rule number: 1455 opt_array_cast.1 */
		0b000100000000000000000, /* Rule number: 1456 function_call_keyword.0 */
		0b000000000000000100000, /* Rule number: 1457 function_call_keyword.1 */
		0b000000000000000001000, /* Rule number: 1458 function_call_keyword.2 */
		0b000000000000000000100, /* Rule number: 1459 function_call_keyword.3 */
		0b000000000000000001000, /* Rule number: 1460 function_call_keyword.4 */
		0b000000000000000001000, /* Rule number: 1461 function_call_keyword.5 */
		0b000000000000000000001, /* Rule number: 1462 function_call_keyword.6 */
		0b000000000100000000000, /* Rule number: 1463 function_call_keyword.7 */
		0b000000000000010000000, /* Rule number: 1464 function_call_keyword.8 */
		0b000001000000000000000, /* Rule number: 1465 function_call_keyword.9 */
		0b000000000000000000010, /* Rule number: 1466 function_call_keyword.10 */
		0b000000000000000000010, /* Rule number: 1467 function_call_keyword.11 */
		0b100000000000000000000, /* Rule number: 1468 function_call_keyword.12 */
		0b001000000000000000000, /* Rule number: 1469 function_call_keyword.13 */
		0b000000000000000100000, /* Rule number: 1470 function_call_keyword.14 */
		0b000000010000000000000, /* Rule number: 1471 function_call_keyword.15 */
		0b000000000000000000100, /* Rule number: 1472 function_call_keyword.16 */
		0b000000000000010000000, /* Rule number: 1473 function_call_keyword.17 */
		0b000100000000000000000, /* Rule number: 1474 function_call_keyword.18 */
		0b000000000000001000000, /* Rule number: 1475 function_call_keyword.19 */
		0b000000000010000000000, /* Rule number: 1476 function_call_keyword.20 */
		0b000010000000000000000, /* Rule number: 1477 function_call_keyword.21 */
		0b000000010000000000000, /* Rule number: 1478 function_call_keyword.22 */
		0b000000000100000000000, /* Rule number: 1479 function_call_keyword.23 */
		0b100000000000000000000, /* Rule number: 1480 function_call_keyword.24 */
		0b001000000000000000000, /* Rule number: 1481 function_call_keyword.25 */
		0b000000000000000001000, /* Rule number: 1482 function_call_keyword.26 */
		0b000000000000000001000, /* Rule number: 1483 function_call_keyword.27 */
		0b000000000000000000100, /* Rule number: 1484 function_call_nonkeyword.0 */
		0b000000010000000000000, /* Rule number: 1485 function_call_nonkeyword.1 */
		0b001000000000000000000, /* Rule number: 1486 function_call_nonkeyword.2 */
		0b000000000001000000000, /* Rule number: 1487 function_call_nonkeyword.3 */
		0b100000000000000000000, /* Rule number: 1488 function_call_nonkeyword.4 */
		0b000000000010000000000, /* Rule number: 1489 function_call_nonkeyword.5 */
		0b000000000000000000100, /* Rule number: 1490 function_call_nonkeyword.6 */
		0b000000000000000010000, /* Rule number: 1491 function_call_nonkeyword.7 */
		0b000000000001000000000, /* Rule number: 1492 function_call_nonkeyword.8 */
		0b100000000000000000000, /* Rule number: 1493 function_call_nonkeyword.9 */
		0b000000000000000000100, /* Rule number: 1494 function_call_nonkeyword.10 */
		0b000000000000000010000, /* Rule number: 1495 function_call_nonkeyword.11 */
		0b000000000000100000000, /* Rule number: 1496 function_call_nonkeyword.12 */
		0b100000000000000000000, /* Rule number: 1497 function_call_nonkeyword.13 */
		0b000000100000000000000, /* Rule number: 1498 function_call_nonkeyword.14 */
		0b000000000000000010000, /* Rule number: 1499 function_call_nonkeyword.15 */
		0b000000000000000000010, /* Rule number: 1500 function_call_nonkeyword.16 */
		0b000001000000000000000, /* Rule number: 1501 function_call_nonkeyword.17 */
		0b000000010000000000000, /* Rule number: 1502 function_call_nonkeyword.18 */
		0b000000000010000000000, /* Rule number: 1503 function_call_nonkeyword.19 */
		0b000000000000000100000, /* Rule number: 1504 function_call_nonkeyword.20 */
		0b000000000001000000000, /* Rule number: 1505 function_call_nonkeyword.21 */
		0b000000100000000000000, /* Rule number: 1506 function_call_nonkeyword.22 */
		0b000100000000000000000, /* Rule number: 1507 function_call_nonkeyword.23 */
		0b000000000000000001000, /* Rule number: 1508 opt_returning_type.0 */
		0b000100000000000000000, /* Rule number: 1509 opt_returning_type.1 */
		0b000000100000000000000, /* Rule number: 1510 function_call_conflict.0 */
		0b000000100000000000000, /* Rule number: 1511 function_call_conflict.1 */
		0b000000100000000000000, /* Rule number: 1512 function_call_conflict.2 */
		0b000000000000100000000, /* Rule number: 1513 function_call_conflict.3 */
		0b000000000000000010000, /* Rule number: 1514 function_call_conflict.4 */
		0b000000000000000010000, /* Rule number: 1515 function_call_conflict.5 */
		0b000000000010000000000, /* Rule number: 1516 function_call_conflict.6 */
		0b000000000010000000000, /* Rule number: 1517 function_call_conflict.7 */
		0b000100000000000000000, /* Rule number: 1518 function_call_conflict.8 */
		0b000000000000000001000, /* Rule number: 1519 function_call_conflict.9 */
		0b000010000000000000000, /* Rule number: 1520 function_call_conflict.10 */
		0b000000000000000000001, /* Rule number: 1521 function_call_conflict.11 */
		0b000000000000000000100, /* Rule number: 1522 function_call_conflict.12 */
		0b000000001000000000000, /* Rule number: 1523 function_call_conflict.13 */
		0b000000000000010000000, /* Rule number: 1524 function_call_conflict.14 */
		0b000000000100000000000, /* Rule number: 1525 function_call_conflict.15 */
		0b000000000000000010000, /* Rule number: 1526 function_call_conflict.16 */
		0b000000000000000100000, /* Rule number: 1527 function_call_conflict.17 */
		0b000000000100000000000, /* Rule number: 1528 function_call_conflict.18 */
		0b000000000000000000010, /* Rule number: 1529 function_call_conflict.19 */
		0b000000000000010000000, /* Rule number: 1530 function_call_conflict.20 */
		0b010000000000000000000, /* Rule number: 1531 function_call_conflict.21 */
		0b000000000000000001000, /* Rule number: 1532 function_call_conflict.22 */
		0b000000000010000000000, /* Rule number: 1533 geometry_function.0 */
		0b000000000000000001000, /* Rule number: 1534 geometry_function.1 */
		0b100000000000000000000, /* Rule number: 1535 geometry_function.2 */
		0b000000001000000000000, /* Rule number: 1536 geometry_function.3 */
		0b000100000000000000000, /* Rule number: 1537 geometry_function.4 */
		0b010000000000000000000, /* Rule number: 1538 geometry_function.5 */
		0b001000000000000000000, /* Rule number: 1539 geometry_function.6 */
		0b000000000100000000000, /* Rule number: 1540 function_call_generic.0 */
		0b000000001000000000000, /* Rule number: 1541 function_call_generic.1 */
		0b000001000000000000000, /* Rule number: 1542 fulltext_options.0 */
		0b000000000000000000100, /* Rule number: 1543 fulltext_options.1 */
		0b000000000000000000100, /* Rule number: 1544 opt_natural_language_mode.0 */
		0b000000000000000000010, /* Rule number: 1545 opt_natural_language_mode.1 */
		0b000000000001000000000, /* Rule number: 1546 opt_query_expansion.0 */
		0b000010000000000000000, /* Rule number: 1547 opt_query_expansion.1 */
		0b100000000000000000000, /* Rule number: 1548 opt_udf_expr_list.0 */
		0b000001000000000000000, /* Rule number: 1549 opt_udf_expr_list.1 */
		0b000000000000000100000, /* Rule number: 1550 udf_expr_list.0 */
		0b000000100000000000000, /* Rule number: 1551 udf_expr_list.1 */
		0b001000000000000000000, /* Rule number: 1552 udf_expr.0 */
		0b000001000000000000000, /* Rule number: 1553 set_function_specification.0 */
		0b000000001000000000000, /* Rule number: 1554 set_function_specification.1 */
		0b000000001000000000000, /* Rule number: 1555 sum_expr.0 */
		0b000000000000010000000, /* Rule number: 1556 sum_expr.1 */
		0b000000000010000000000, /* Rule number: 1557 sum_expr.2 */
		0b000010000000000000000, /* Rule number: 1558 sum_expr.3 */
		0b000000000000010000000, /* Rule number: 1559 sum_expr.4 */
		0b000000000010000000000, /* Rule number: 1560 sum_expr.5 */
		0b000100000000000000000, /* Rule number: 1561 sum_expr.6 */
		0b000000000000010000000, /* Rule number: 1562 sum_expr.7 */
		0b000000000000000000010, /* Rule number: 1563 sum_expr.8 */
		0b000000000000010000000, /* Rule number: 1564 sum_expr.9 */
		0b000001000000000000000, /* Rule number: 1565 sum_expr.10 */
		0b000000000000000001000, /* Rule number: 1566 sum_expr.11 */
		0b000000000000000001000, /* Rule number: 1567 sum_expr.12 */
		0b000000000001000000000, /* Rule number: 1568 sum_expr.13 */
		0b000010000000000000000, /* Rule number: 1569 sum_expr.14 */
		0b100000000000000000000, /* Rule number: 1570 sum_expr.15 */
		0b000000000000001000000, /* Rule number: 1571 sum_expr.16 */
		0b000000100000000000000, /* Rule number: 1572 sum_expr.17 */
		0b000000000000000001000, /* Rule number: 1573 sum_expr.18 */
		0b001000000000000000000, /* Rule number: 1574 sum_expr.19 */
		0b010000000000000000000, /* Rule number: 1575 sum_expr.20 */
		0b000000001000000000000, /* Rule number: 1576 sum_expr.21 */
		0b010000000000000000000, /* Rule number: 1577 sum_expr.22 */
		0b000000000000000000010, /* Rule number: 1578 sampling_method.0 */
		0b000001000000000000000, /* Rule number: 1579 sampling_method.1 */
		0b000010000000000000000, /* Rule number: 1580 sampling_percentage.0 */
		0b000100000000000000000, /* Rule number: 1581 sampling_percentage.1 */
		0b000100000000000000000, /* Rule number: 1582 sampling_percentage.2 */
		0b000000000000000000001, /* Rule number: 1583 opt_tablesample_clause.0 */
		0b010000000000000000000, /* Rule number: 1584 opt_tablesample_clause.1 */
		0b000000000001000000000, /* Rule number: 1585 window_func_call.0 */
		0b000000000000000000100, /* Rule number: 1586 window_func_call.1 */
		0b000000000001000000000, /* Rule number: 1587 window_func_call.2 */
		0b000000010000000000000, /* Rule number: 1588 window_func_call.3 */
		0b000000100000000000000, /* Rule number: 1589 window_func_call.4 */
		0b000000000000001000000, /* Rule number: 1590 window_func_call.5 */
		0b000000000100000000000, /* Rule number: 1591 window_func_call.6 */
		0b000000000000000000100, /* Rule number: 1592 window_func_call.7 */
		0b000010000000000000000, /* Rule number: 1593 window_func_call.8 */
		0b100000000000000000000, /* Rule number: 1594 window_func_call.9 */
		0b000000000000000000100, /* Rule number: 1595 window_func_call.10 */
		0b000000000000000000100, /* Rule number: 1596 opt_lead_lag_info.0 */
		0b100000000000000000000, /* Rule number: 1597 opt_lead_lag_info.1 */
		0b000000000001000000000, /* Rule number: 1598 stable_integer.0 */
		0b000000000000000000001, /* Rule number: 1599 stable_integer.1 */
		0b000000000000000000001, /* Rule number: 1600 param_or_var.0 */
		0b000000010000000000000, /* Rule number: 1601 param_or_var.1 */
		0b000000000000000100000, /* Rule number: 1602 param_or_var.2 */
		0b010000000000000000000, /* Rule number: 1603 opt_ll_default.0 */
		0b001000000000000000000, /* Rule number: 1604 opt_ll_default.1 */
		0b000100000000000000000, /* Rule number: 1605 opt_null_treatment.0 */
		0b000010000000000000000, /* Rule number: 1606 opt_null_treatment.1 */
		0b000000001000000000000, /* Rule number: 1607 opt_null_treatment.2 */
		0b000000000000000000010, /* Rule number: 1608 opt_from_first_last.0 */
		0b010000000000000000000, /* Rule number: 1609 opt_from_first_last.1 */
		0b000000000000000000010, /* Rule number: 1610 opt_from_first_last.2 */
		0b000010000000000000000, /* Rule number: 1611 opt_windowing_clause.0 */
		0b000000100000000000000, /* Rule number: 1612 opt_windowing_clause.1 */
		0b000000010000000000000, /* Rule number: 1613 windowing_clause.0 */
		0b000000000001000000000, /* Rule number: 1614 window_name_or_spec.0 */
		0b000000000100000000000, /* Rule number: 1615 window_name_or_spec.1 */
		0b000000000000000001000, /* Rule number: 1616 window_name.0 */
		0b000000001000000000000, /* Rule number: 1617 window_spec.0 */
		0b000000000010000000000, /* Rule number: 1618 window_spec_details.0 */
		0b000000100000000000000, /* Rule number: 1619 opt_existing_window_name.0 */
		0b000000001000000000000, /* Rule number: 1620 opt_existing_window_name.1 */
		0b000010000000000000000, /* Rule number: 1621 opt_partition_clause.0 */
		0b000000000010000000000, /* Rule number: 1622 opt_partition_clause.1 */
		0b000000000000000000010, /* Rule number: 1623 opt_window_order_by_clause.0 */
		0b000001000000000000000, /* Rule number: 1624 opt_window_order_by_clause.1 */
		0b000000000000010000000, /* Rule number: 1625 opt_window_frame_clause.0 */
		0b000000000001000000000, /* Rule number: 1626 opt_window_frame_clause.1 */
		0b000000000000000000010, /* Rule number: 1627 window_frame_extent.0 */
		0b001000000000000000000, /* Rule number: 1628 window_frame_extent.1 */
		0b000000000100000000000, /* Rule number: 1629 window_frame_start.0 */
		0b001000000000000000000, /* Rule number: 1630 window_frame_start.1 */
		0b000000000000000000100, /* Rule number: 1631 window_frame_start.2 */
		0b000000000000010000000, /* Rule number: 1632 window_frame_start.3 */
		0b000000100000000000000, /* Rule number: 1633 window_frame_start.4 */
		0b000000001000000000000, /* Rule number: 1634 window_frame_between.0 */
		0b000000000000000010000, /* Rule number: 1635 window_frame_bound.0 */
		0b000000100000000000000, /* Rule number: 1636 window_frame_bound.1 */
		0b000001000000000000000, /* Rule number: 1637 window_frame_bound.2 */
		0b000000000000100000000, /* Rule number: 1638 window_frame_bound.3 */
		0b000000000000000100000, /* Rule number: 1639 window_frame_bound.4 */
		0b010000000000000000000, /* Rule number: 1640 opt_window_frame_exclusion.0 */
		0b000000001000000000000, /* Rule number: 1641 opt_window_frame_exclusion.1 */
		0b000000001000000000000, /* Rule number: 1642 opt_window_frame_exclusion.2 */
		0b000000100000000000000, /* Rule number: 1643 opt_window_frame_exclusion.3 */
		0b000000000100000000000, /* Rule number: 1644 opt_window_frame_exclusion.4 */
		0b000001000000000000000, /* Rule number: 1645 window_frame_units.0 */
		0b000000000000010000000, /* Rule number: 1646 window_frame_units.1 */
		0b100000000000000000000, /* Rule number: 1647 window_frame_units.2 */
		0b000000000010000000000, /* Rule number: 1648 grouping_operation.0 */
		0b100000000000000000000, /* Rule number: 1649 in_expression_user_variable_assignment.0 */
		0b000000000000010000000, /* Rule number: 1650 rvalue_system_or_user_variable.0 */
		0b000000000000000000100, /* Rule number: 1651 rvalue_system_or_user_variable.1 */
		0b000000100000000000000, /* Rule number: 1652 opt_distinct.0 */
		0b000000000010000000000, /* Rule number: 1653 opt_distinct.1 */
		0b000000000000000000010, /* Rule number: 1654 opt_gconcat_separator.0 */
		0b000000100000000000000, /* Rule number: 1655 opt_gconcat_separator.1 */
		0b000000000000000010000, /* Rule number: 1656 opt_gorder_clause.0 */
		0b000000001000000000000, /* Rule number: 1657 opt_gorder_clause.1 */
		0b000000000000010000000, /* Rule number: 1658 gorder_list.0 */
		0b000000000000000000001, /* Rule number: 1659 gorder_list.1 */
		0b000000010000000000000, /* Rule number: 1660 in_sum_expr.0 */
		0b000000000000000000100, /* Rule number: 1661 cast_type.0 */
		0b000000001000000000000, /* Rule number: 1662 cast_type.1 */
		0b000000000000000001000, /* Rule number: 1663 cast_type.2 */
		0b001000000000000000000, /* Rule number: 1664 cast_type.3 */
		0b100000000000000000000, /* Rule number: 1665 cast_type.4 */
		0b000001000000000000000, /* Rule number: 1666 cast_type.5 */
		0b000000000100000000000, /* Rule number: 1667 cast_type.6 */
		0b000010000000000000000, /* Rule number: 1668 cast_type.7 */
		0b000000000000000000010, /* Rule number: 1669 cast_type.8 */
		0b000000000000000100000, /* Rule number: 1670 cast_type.9 */
		0b010000000000000000000, /* Rule number: 1671 cast_type.10 */
		0b000000000000010000000, /* Rule number: 1672 cast_type.11 */
		0b000000000000000000001, /* Rule number: 1673 cast_type.12 */
		0b000000000000001000000, /* Rule number: 1674 cast_type.13 */
		0b000000000000000010000, /* Rule number: 1675 cast_type.14 */
		0b000000000000000000010, /* Rule number: 1676 cast_type.15 */
		0b000000000000100000000, /* Rule number: 1677 cast_type.16 */
		0b000000000000100000000, /* Rule number: 1678 cast_type.17 */
		0b000000000000000100000, /* Rule number: 1679 cast_type.18 */
		0b000000000000000001000, /* Rule number: 1680 cast_type.19 */
		0b000000000000000000100, /* Rule number: 1681 cast_type.20 */
		0b100000000000000000000, /* Rule number: 1682 cast_type.21 */
		0b000000010000000000000, /* Rule number: 1683 opt_expr_list.0 */
		0b000000000000000100000, /* Rule number: 1684 opt_expr_list.1 */
		0b001000000000000000000, /* Rule number: 1685 expr_list.0 */
		0b000000000100000000000, /* Rule number: 1686 expr_list.1 */
		0b010000000000000000000, /* Rule number: 1687 ident_list_arg.0 */
		0b000000000000000000001, /* Rule number: 1688 ident_list_arg.1 */
		0b000000000000001000000, /* Rule number: 1689 ident_list.0 */
		0b000000100000000000000, /* Rule number: 1690 ident_list.1 */
		0b000000000000010000000, /* Rule number: 1691 opt_expr.0 */
		0b000000000001000000000, /* Rule number: 1692 opt_expr.1 */
		0b000000000000010000000, /* Rule number: 1693 opt_else.0 */
		0b000100000000000000000, /* Rule number: 1694 opt_else.1 */
		0b000000010000000000000, /* Rule number: 1695 when_list.0 */
		0b000000000000010000000, /* Rule number: 1696 when_list.1 */
		0b000000000000000000100, /* Rule number: 1697 table_reference.0 */
		0b001000000000000000000, /* Rule number: 1698 table_reference.1 */
		0b000000100000000000000, /* Rule number: 1699 table_reference.2 */
		0b000001000000000000000, /* Rule number: 1700 esc_table_reference.0 */
		0b000000000000000000100, /* Rule number: 1701 esc_table_reference.1 */
		0b000000000000000000001, /* Rule number: 1702 joined_table.0 */
		0b000000010000000000000, /* Rule number: 1703 joined_table.1 */
		0b000100000000000000000, /* Rule number: 1704 joined_table.2 */
		0b000000000000010000000, /* Rule number: 1705 joined_table.3 */
		0b000000000000001000000, /* Rule number: 1706 joined_table.4 */
		0b000000000000000000010, /* Rule number: 1707 joined_table.5 */
		0b000000010000000000000, /* Rule number: 1708 natural_join_type.0 */
		0b000000000001000000000, /* Rule number: 1709 natural_join_type.1 */
		0b000000000000010000000, /* Rule number: 1710 natural_join_type.2 */
		0b000000100000000000000, /* Rule number: 1711 inner_join_type.0 */
		0b000000000000000010000, /* Rule number: 1712 inner_join_type.1 */
		0b000000000000000010000, /* Rule number: 1713 inner_join_type.2 */
		0b000000010000000000000, /* Rule number: 1714 inner_join_type.3 */
		0b000000000000000100000, /* Rule number: 1715 outer_join_type.0 */
		0b001000000000000000000, /* Rule number: 1716 outer_join_type.1 */
		0b000000000000000100000, /* Rule number: 1717 opt_inner.0 */
		0b100000000000000000000, /* Rule number: 1718 opt_inner.1 */
		0b000000000000000010000, /* Rule number: 1719 opt_outer.0 */
		0b000000000000000100000, /* Rule number: 1720 opt_outer.1 */
		0b000000000100000000000, /* Rule number: 1721 opt_use_partition.0 */
		0b000000000000000000001, /* Rule number: 1722 opt_use_partition.1 */
		0b000000000001000000000, /* Rule number: 1723 use_partition.0 */
		0b000000010000000000000, /* Rule number: 1724 table_factor.0 */
		0b100000000000000000000, /* Rule number: 1725 table_factor.1 */
		0b001000000000000000000, /* Rule number: 1726 table_factor.2 */
		0b000000000000000001000, /* Rule number: 1727 table_factor.3 */
		0b000010000000000000000, /* Rule number: 1728 table_factor.4 */
		0b000000000100000000000, /* Rule number: 1729 table_factor.5 */
		0b000000000000001000000, /* Rule number: 1730 table_reference_list_parens.0 */
		0b000000000100000000000, /* Rule number: 1731 table_reference_list_parens.1 */
		0b000000000000000001000, /* Rule number: 1732 single_table_parens.0 */
		0b000000000000001000000, /* Rule number: 1733 single_table_parens.1 */
		0b000000000000100000000, /* Rule number: 1734 single_table.0 */
		0b100000000000000000000, /* Rule number: 1735 joined_table_parens.0 */
		0b100000000000000000000, /* Rule number: 1736 joined_table_parens.1 */
		0b000000100000000000000, /* Rule number: 1737 derived_table.0 */
		0b000000000010000000000, /* Rule number: 1738 derived_table.1 */
		0b000000100000000000000, /* Rule number: 1739 table_function.0 */
		0b000001000000000000000, /* Rule number: 1740 columns_clause.0 */
		0b000000000010000000000, /* Rule number: 1741 columns_list.0 */
		0b010000000000000000000, /* Rule number: 1742 columns_list.1 */
		0b000000000000010000000, /* Rule number: 1743 jt_column.0 */
		0b000000001000000000000, /* Rule number: 1744 jt_column.1 */
		0b000000000100000000000, /* Rule number: 1745 jt_column.2 */
		0b000001000000000000000, /* Rule number: 1746 jt_column_type.0 */
		0b000000000000000000010, /* Rule number: 1747 jt_column_type.1 */
		0b000000000001000000000, /* Rule number: 1748 opt_on_empty_or_error.0 */
		0b000000000000000010000, /* Rule number: 1749 opt_on_empty_or_error.1 */
		0b000001000000000000000, /* Rule number: 1750 opt_on_empty_or_error.2 */
		0b000000000000001000000, /* Rule number: 1751 opt_on_empty_or_error.3 */
		0b000000000000000100000, /* Rule number: 1752 opt_on_empty_or_error_json_table.0 */
		0b100000000000000000000, /* Rule number: 1753 opt_on_empty_or_error_json_table.1 */
		0b000000000000100000000, /* Rule number: 1754 on_empty.0 */
		0b000000000100000000000, /* Rule number: 1755 on_error.0 */
		0b000000000100000000000, /* Rule number: 1756 json_on_response.0 */
		0b000000000000000000001, /* Rule number: 1757 json_on_response.1 */
		0b000000100000000000000, /* Rule number: 1758 json_on_response.2 */
		0b000000000000000100000, /* Rule number: 1759 index_hint_clause.0 */
		0b010000000000000000000, /* Rule number: 1760 index_hint_clause.1 */
		0b000000000001000000000, /* Rule number: 1761 index_hint_clause.2 */
		0b000000000010000000000, /* Rule number: 1762 index_hint_clause.3 */
		0b000000000000010000000, /* Rule number: 1763 index_hint_type.0 */
		0b010000000000000000000, /* Rule number: 1764 index_hint_type.1 */
		0b000000000000100000000, /* Rule number: 1765 index_hint_definition.0 */
		0b000000000010000000000, /* Rule number: 1766 index_hint_definition.1 */
		0b000000000010000000000, /* Rule number: 1767 index_hints_list.0 */
		0b000000000000000000100, /* Rule number: 1768 index_hints_list.1 */
		0b000000000000000001000, /* Rule number: 1769 opt_index_hints_list.0 */
		0b000000000000000000010, /* Rule number: 1770 opt_index_hints_list.1 */
		0b000000000010000000000, /* Rule number: 1771 opt_key_definition.0 */
		0b000000000000100000000, /* Rule number: 1772 opt_key_usage_list.0 */
		0b000000010000000000000, /* Rule number: 1773 opt_key_usage_list.1 */
		0b000000000100000000000, /* Rule number: 1774 key_usage_element.0 */
		0b000000000100000000000, /* Rule number: 1775 key_usage_element.1 */
		0b000100000000000000000, /* Rule number: 1776 key_usage_list.0 */
		0b000000000001000000000, /* Rule number: 1777 key_usage_list.1 */
		0b000000000100000000000, /* Rule number: 1778 using_list.0 */
		0b000000000000000000001, /* Rule number: 1779 ident_string_list.0 */
		0b000001000000000000000, /* Rule number: 1780 ident_string_list.1 */
		0b000000000000001000000, /* Rule number: 1781 interval.0 */
		0b001000000000000000000, /* Rule number: 1782 interval.1 */
		0b000000000000000000010, /* Rule number: 1783 interval.2 */
		0b000000000010000000000, /* Rule number: 1784 interval.3 */
		0b001000000000000000000, /* Rule number: 1785 interval.4 */
		0b000000000000001000000, /* Rule number: 1786 interval.5 */
		0b000000000000000010000, /* Rule number: 1787 interval.6 */
		0b000000010000000000000, /* Rule number: 1788 interval.7 */
		0b000100000000000000000, /* Rule number: 1789 interval.8 */
		0b000000000000000000001, /* Rule number: 1790 interval.9 */
		0b000100000000000000000, /* Rule number: 1791 interval.10 */
		0b100000000000000000000, /* Rule number: 1792 interval.11 */
		0b000000000000000010000, /* Rule number: 1793 interval_time_stamp.0 */
		0b000000000000000100000, /* Rule number: 1794 interval_time_stamp.1 */
		0b000000000000000000100, /* Rule number: 1795 interval_time_stamp.2 */
		0b000000000000000000100, /* Rule number: 1796 interval_time_stamp.3 */
		0b000000000000000001000, /* Rule number: 1797 interval_time_stamp.4 */
		0b000000000000000100000, /* Rule number: 1798 interval_time_stamp.5 */
		0b000100000000000000000, /* Rule number: 1799 interval_time_stamp.6 */
		0b000000000000000000010, /* Rule number: 1800 interval_time_stamp.7 */
		0b000000000000000001000, /* Rule number: 1801 interval_time_stamp.8 */
		0b000000000000000001000, /* Rule number: 1802 date_time_type.0 */
		0b000000000100000000000, /* Rule number: 1803 date_time_type.1 */
		0b001000000000000000000, /* Rule number: 1804 date_time_type.2 */
		0b000000000100000000000, /* Rule number: 1805 date_time_type.3 */
		0b001000000000000000000, /* Rule number: 1806 opt_as.0 */
		0b000000000000000001000, /* Rule number: 1807 opt_as.1 */
		0b000000100000000000000, /* Rule number: 1808 opt_table_alias.0 */
		0b000000000000000000100, /* Rule number: 1809 opt_table_alias.1 */
		0b000000001000000000000, /* Rule number: 1810 opt_all.0 */
		0b001000000000000000000, /* Rule number: 1811 opt_all.1 */
		0b010000000000000000000, /* Rule number: 1812 opt_where_clause.0 */
		0b000000000000000010000, /* Rule number: 1813 opt_where_clause.1 */
		0b000000000000100000000, /* Rule number: 1814 where_clause.0 */
		0b010000000000000000000, /* Rule number: 1815 opt_having_clause.0 */
		0b000000000001000000000, /* Rule number: 1816 opt_having_clause.1 */
		0b000000000000000100000, /* Rule number: 1817 opt_qualify_clause.0 */
		0b010000000000000000000, /* Rule number: 1818 opt_qualify_clause.1 */
		0b000000000010000000000, /* Rule number: 1819 with_clause.0 */
		0b000000000000000010000, /* Rule number: 1820 with_clause.1 */
		0b000000100000000000000, /* Rule number: 1821 with_list.0 */
		0b001000000000000000000, /* Rule number: 1822 with_list.1 */
		0b001000000000000000000, /* Rule number: 1823 common_table_expr.0 */
		0b000000100000000000000, /* Rule number: 1824 opt_derived_column_list.0 */
		0b000000000000000100000, /* Rule number: 1825 opt_derived_column_list.1 */
		0b000000000000010000000, /* Rule number: 1826 simple_ident_list.0 */
		0b000001000000000000000, /* Rule number: 1827 simple_ident_list.1 */
		0b000000010000000000000, /* Rule number: 1828 opt_window_clause.0 */
		0b001000000000000000000, /* Rule number: 1829 opt_window_clause.1 */
		0b000000001000000000000, /* Rule number: 1830 window_definition_list.0 */
		0b000000001000000000000, /* Rule number: 1831 window_definition_list.1 */
		0b000000000000000000100, /* Rule number: 1832 window_definition.0 */
		0b000100000000000000000, /* Rule number: 1833 opt_group_clause.0 */
		0b000000000001000000000, /* Rule number: 1834 opt_group_clause.1 */
		0b000000000000000000001, /* Rule number: 1835 opt_group_clause.2 */
		0b000000000001000000000, /* Rule number: 1836 opt_group_clause.3 */
		0b000000000000000001000, /* Rule number: 1837 group_list.0 */
		0b000000000010000000000, /* Rule number: 1838 group_list.1 */
		0b000000000000000000001, /* Rule number: 1839 olap_opt.0 */
		0b000000001000000000000, /* Rule number: 1840 olap_opt.1 */
		0b000000000000010000000, /* Rule number: 1841 alter_order_list.0 */
		0b000000000100000000000, /* Rule number: 1842 alter_order_list.1 */
		0b100000000000000000000, /* Rule number: 1843 alter_order_item.0 */
		0b000000000001000000000, /* Rule number: 1844 opt_order_clause.0 */
		0b000000000010000000000, /* Rule number: 1845 opt_order_clause.1 */
		0b000000100000000000000, /* Rule number: 1846 order_clause.0 */
		0b100000000000000000000, /* Rule number: 1847 order_list.0 */
		0b000000001000000000000, /* Rule number: 1848 order_list.1 */
		0b000000000010000000000, /* Rule number: 1849 opt_ordering_direction.0 */
		0b000000000100000000000, /* Rule number: 1850 opt_ordering_direction.1 */
		0b000000000010000000000, /* Rule number: 1851 ordering_direction.0 */
		0b000010000000000000000, /* Rule number: 1852 ordering_direction.1 */
		0b000000000000000000001, /* Rule number: 1853 opt_limit_clause.0 */
		0b000000000100000000000, /* Rule number: 1854 opt_limit_clause.1 */
		0b000000000000000001000, /* Rule number: 1855 limit_clause.0 */
		0b000000000000000000010, /* Rule number: 1856 limit_options.0 */
		0b000000000000000001000, /* Rule number: 1857 limit_options.1 */
		0b000000001000000000000, /* Rule number: 1858 limit_options.2 */
		0b000000000100000000000, /* Rule number: 1859 limit_option.0 */
		0b000000000000100000000, /* Rule number: 1860 limit_option.1 */
		0b000000000000100000000, /* Rule number: 1861 limit_option.2 */
		0b001000000000000000000, /* Rule number: 1862 limit_option.3 */
		0b000000001000000000000, /* Rule number: 1863 limit_option.4 */
		0b000000001000000000000, /* Rule number: 1864 opt_simple_limit.0 */
		0b000000100000000000000, /* Rule number: 1865 opt_simple_limit.1 */
		0b001000000000000000000, /* Rule number: 1866 ulong_num.0 */
		0b000000000000000000100, /* Rule number: 1867 ulong_num.1 */
		0b000010000000000000000, /* Rule number: 1868 ulong_num.2 */
		0b000000001000000000000, /* Rule number: 1869 ulong_num.3 */
		0b000000000000010000000, /* Rule number: 1870 ulong_num.4 */
		0b000000000000001000000, /* Rule number: 1871 ulong_num.5 */
		0b000000000000100000000, /* Rule number: 1872 real_ulong_num.0 */
		0b000001000000000000000, /* Rule number: 1873 real_ulong_num.1 */
		0b000000100000000000000, /* Rule number: 1874 real_ulong_num.2 */
		0b000000000000000000100, /* Rule number: 1875 real_ulong_num.3 */
		0b000000000000000000010, /* Rule number: 1876 real_ulong_num.4 */
		0b000000001000000000000, /* Rule number: 1877 ulonglong_num.0 */
		0b000000000000010000000, /* Rule number: 1878 ulonglong_num.1 */
		0b000000000000100000000, /* Rule number: 1879 ulonglong_num.2 */
		0b000000000000000000100, /* Rule number: 1880 ulonglong_num.3 */
		0b000000000000010000000, /* Rule number: 1881 ulonglong_num.4 */
		0b000100000000000000000, /* Rule number: 1882 real_ulonglong_num.0 */
		0b000000000000000000010, /* Rule number: 1883 real_ulonglong_num.1 */
		0b000000000000000100000, /* Rule number: 1884 real_ulonglong_num.2 */
		0b000000000000000000001, /* Rule number: 1885 real_ulonglong_num.3 */
		0b000000000000000001000, /* Rule number: 1886 real_ulonglong_num.4 */
		0b100000000000000000000, /* Rule number: 1887 dec_num_error.0 */
		0b000000000000000100000, /* Rule number: 1888 dec_num.0 */
		0b000000010000000000000, /* Rule number: 1889 dec_num.1 */
		0b000000000000001000000, /* Rule number: 1890 select_var_list.0 */
		0b000000000100000000000, /* Rule number: 1891 select_var_list.1 */
		0b000000000001000000000, /* Rule number: 1892 select_var_ident.0 */
		0b000000100000000000000, /* Rule number: 1893 select_var_ident.1 */
		0b000100000000000000000, /* Rule number: 1894 into_clause.0 */
		0b000000001000000000000, /* Rule number: 1895 into_destination.0 */
		0b000000000010000000000, /* Rule number: 1896 into_destination.1 */
		0b000000000000000000010, /* Rule number: 1897 into_destination.2 */
		0b001000000000000000000, /* Rule number: 1898 do_stmt.0 */
		0b000000000000000000100, /* Rule number: 1899 drop_table_stmt.0 */
		0b000000000000010000000, /* Rule number: 1900 drop_index_stmt.0 */
		0b000000000000000000100, /* Rule number: 1901 drop_database_stmt.0 */
		0b000000000000000000001, /* Rule number: 1902 drop_function_stmt.0 */
		0b000000000000100000000, /* Rule number: 1903 drop_function_stmt.1 */
		0b000000000000000001000, /* Rule number: 1904 drop_resource_group_stmt.0 */
		0b100000000000000000000, /* Rule number: 1905 drop_procedure_stmt.0 */
		0b000000000000000000010, /* Rule number: 1906 drop_user_stmt.0 */
		0b000010000000000000000, /* Rule number: 1907 drop_view_stmt.0 */
		0b000000000000000000001, /* Rule number: 1908 drop_event_stmt.0 */
		0b000100000000000000000, /* Rule number: 1909 drop_trigger_stmt.0 */
		0b000000000000100000000, /* Rule number: 1910 drop_tablespace_stmt.0 */
		0b000100000000000000000, /* Rule number: 1911 drop_undo_tablespace_stmt.0 */
		0b000000010000000000000, /* Rule number: 1912 drop_logfile_stmt.0 */
		0b000000000001000000000, /* Rule number: 1913 drop_server_stmt.0 */
		0b000000000000000010000, /* Rule number: 1914 drop_srs_stmt.0 */
		0b000000000001000000000, /* Rule number: 1915 drop_role_stmt.0 */
		0b000000000000000010000, /* Rule number: 1916 table_list.0 */
		0b000000100000000000000, /* Rule number: 1917 table_list.1 */
		0b000010000000000000000, /* Rule number: 1918 table_alias_ref_list.0 */
		0b000100000000000000000, /* Rule number: 1919 table_alias_ref_list.1 */
		0b000000000000001000000, /* Rule number: 1920 if_exists.0 */
		0b000000000000000000001, /* Rule number: 1921 if_exists.1 */
		0b000000000000000000010, /* Rule number: 1922 opt_ignore_unknown_user.0 */
		0b000100000000000000000, /* Rule number: 1923 opt_ignore_unknown_user.1 */
		0b000000000000100000000, /* Rule number: 1924 opt_temporary.0 */
		0b000000000000000000100, /* Rule number: 1925 opt_temporary.1 */
		0b000000000000000001000, /* Rule number: 1926 opt_drop_ts_options.0 */
		0b000000100000000000000, /* Rule number: 1927 opt_drop_ts_options.1 */
		0b000000000100000000000, /* Rule number: 1928 drop_ts_option_list.0 */
		0b000000000000010000000, /* Rule number: 1929 drop_ts_option_list.1 */
		0b000000000000010000000, /* Rule number: 1930 drop_ts_option.0 */
		0b000000100000000000000, /* Rule number: 1931 drop_ts_option.1 */
		0b000000000000000100000, /* Rule number: 1932 insert_stmt.0 */
		0b000000000000000100000, /* Rule number: 1933 insert_stmt.1 */
		0b001000000000000000000, /* Rule number: 1934 insert_stmt.2 */
		0b000000000000010000000, /* Rule number: 1935 replace_stmt.0 */
		0b000010000000000000000, /* Rule number: 1936 replace_stmt.1 */
		0b000000000001000000000, /* Rule number: 1937 replace_stmt.2 */
		0b000000000000100000000, /* Rule number: 1938 insert_lock_option.0 */
		0b000000000000000001000, /* Rule number: 1939 insert_lock_option.1 */
		0b000001000000000000000, /* Rule number: 1940 insert_lock_option.2 */
		0b000000000000100000000, /* Rule number: 1941 insert_lock_option.3 */
		0b000000001000000000000, /* Rule number: 1942 replace_lock_option.0 */
		0b000000001000000000000, /* Rule number: 1943 replace_lock_option.1 */
		0b000000000100000000000, /* Rule number: 1944 opt_INTO.0 */
		0b000000000000000000100, /* Rule number: 1945 opt_INTO.1 */
		0b000100000000000000000, /* Rule number: 1946 insert_from_constructor.0 */
		0b000010000000000000000, /* Rule number: 1947 insert_from_constructor.1 */
		0b000000000000000000001, /* Rule number: 1948 insert_from_constructor.2 */
		0b000000100000000000000, /* Rule number: 1949 insert_query_expression.0 */
		0b000001000000000000000, /* Rule number: 1950 insert_query_expression.1 */
		0b000000000000100000000, /* Rule number: 1951 insert_query_expression.2 */
		0b000010000000000000000, /* Rule number: 1952 insert_columns.0 */
		0b000010000000000000000, /* Rule number: 1953 insert_columns.1 */
		0b000000000000000000001, /* Rule number: 1954 insert_values.0 */
		0b000000000000100000000, /* Rule number: 1955 query_expression_with_opt_locking_clauses.0 */
		0b000010000000000000000, /* Rule number: 1956 query_expression_with_opt_locking_clauses.1 */
		0b000000000000000000010, /* Rule number: 1957 value_or_values.0 */
		0b000000100000000000000, /* Rule number: 1958 value_or_values.1 */
		0b000000000001000000000, /* Rule number: 1959 values_list.0 */
		0b000000000001000000000, /* Rule number: 1960 values_list.1 */
		0b000000001000000000000, /* Rule number: 1961 values_row_list.0 */
		0b000100000000000000000, /* Rule number: 1962 values_row_list.1 */
		0b000000100000000000000, /* Rule number: 1963 equal.0 */
		0b000000010000000000000, /* Rule number: 1964 equal.1 */
		0b000000000000000001000, /* Rule number: 1965 opt_equal.0 */
		0b000010000000000000000, /* Rule number: 1966 opt_equal.1 */
		0b000000000010000000000, /* Rule number: 1967 row_value.0 */
		0b000000000000000000100, /* Rule number: 1968 row_value_explicit.0 */
		0b000000000100000000000, /* Rule number: 1969 opt_values.0 */
		0b000000000000000000100, /* Rule number: 1970 opt_values.1 */
		0b100000000000000000000, /* Rule number: 1971 values.0 */
		0b010000000000000000000, /* Rule number: 1972 values.1 */
		0b000000000100000000000, /* Rule number: 1973 expr_or_default.0 */
		0b000000000000001000000, /* Rule number: 1974 expr_or_default.1 */
		0b000000000000000000001, /* Rule number: 1975 opt_values_reference.0 */
		0b000000000100000000000, /* Rule number: 1976 opt_values_reference.1 */
		0b000001000000000000000, /* Rule number: 1977 opt_insert_update_list.0 */
		0b000000000000100000000, /* Rule number: 1978 opt_insert_update_list.1 */
		0b000000000010000000000, /* Rule number: 1979 update_stmt.0 */
		0b100000000000000000000, /* Rule number: 1980 opt_with_clause.0 */
		0b000001000000000000000, /* Rule number: 1981 opt_with_clause.1 */
		0b000010000000000000000, /* Rule number: 1982 update_list.0 */
		0b000000000000100000000, /* Rule number: 1983 update_list.1 */
		0b010000000000000000000, /* Rule number: 1984 update_elem.0 */
		0b000000000000000001000, /* Rule number: 1985 opt_low_priority.0 */
		0b000000000000000000100, /* Rule number: 1986 opt_low_priority.1 */
		0b000100000000000000000, /* Rule number: 1987 delete_stmt.0 */
		0b000000000000000010000, /* Rule number: 1988 delete_stmt.1 */
		0b000000000000000100000, /* Rule number: 1989 delete_stmt.2 */
		0b000000000100000000000, /* Rule number: 1990 opt_wild.0 */
		0b000100000000000000000, /* Rule number: 1991 opt_wild.1 */
		0b000000001000000000000, /* Rule number: 1992 opt_delete_options.0 */
		0b000000100000000000000, /* Rule number: 1993 opt_delete_options.1 */
		0b000000000000000000010, /* Rule number: 1994 opt_delete_option.0 */
		0b001000000000000000000, /* Rule number: 1995 opt_delete_option.1 */
		0b100000000000000000000, /* Rule number: 1996 opt_delete_option.2 */
		0b000000000000000010000, /* Rule number: 1997 truncate_stmt.0 */
		0b000000000000000010000, /* Rule number: 1998 opt_table.0 */
		0b000010000000000000000, /* Rule number: 1999 opt_table.1 */
		0b000000000000000001000, /* Rule number: 2000 opt_profile_defs.0 */
		0b000000000000000000010, /* Rule number: 2001 opt_profile_defs.1 */
		0b000000100000000000000, /* Rule number: 2002 profile_defs.0 */
		0b000000000000000001000, /* Rule number: 2003 profile_defs.1 */
		0b000000001000000000000, /* Rule number: 2004 profile_def.0 */
		0b010000000000000000000, /* Rule number: 2005 profile_def.1 */
		0b000000000001000000000, /* Rule number: 2006 profile_def.2 */
		0b000000000000000000010, /* Rule number: 2007 profile_def.3 */
		0b010000000000000000000, /* Rule number: 2008 profile_def.4 */
		0b000000000000000000001, /* Rule number: 2009 profile_def.5 */
		0b000100000000000000000, /* Rule number: 2010 profile_def.6 */
		0b000000000000000100000, /* Rule number: 2011 profile_def.7 */
		0b000100000000000000000, /* Rule number: 2012 profile_def.8 */
		0b000000000000001000000, /* Rule number: 2013 opt_for_query.0 */
		0b000000000000010000000, /* Rule number: 2014 opt_for_query.1 */
		0b000000000000000010000, /* Rule number: 2015 show_databases_stmt.0 */
		0b000000000000001000000, /* Rule number: 2016 show_tables_stmt.0 */
		0b000000000100000000000, /* Rule number: 2017 show_triggers_stmt.0 */
		0b000000000100000000000, /* Rule number: 2018 show_events_stmt.0 */
		0b000000100000000000000, /* Rule number: 2019 show_table_status_stmt.0 */
		0b000000000010000000000, /* Rule number: 2020 show_open_tables_stmt.0 */
		0b000000000000000100000, /* Rule number: 2021 show_plugins_stmt.0 */
		0b000000000001000000000, /* Rule number: 2022 show_engine_logs_stmt.0 */
		0b000000000000000001000, /* Rule number: 2023 show_engine_mutex_stmt.0 */
		0b000000000010000000000, /* Rule number: 2024 show_engine_status_stmt.0 */
		0b000000000000000001000, /* Rule number: 2025 show_columns_stmt.0 */
		0b001000000000000000000, /* Rule number: 2026 show_binary_logs_stmt.0 */
		0b000010000000000000000, /* Rule number: 2027 show_replicas_stmt.0 */
		0b000000000000010000000, /* Rule number: 2028 show_binlog_events_stmt.0 */
		0b000000000000001000000, /* Rule number: 2029 show_relaylog_events_stmt.0 */
		0b000000000000000000001, /* Rule number: 2030 show_keys_stmt.0 */
		0b000000000000010000000, /* Rule number: 2031 show_engines_stmt.0 */
		0b000000100000000000000, /* Rule number: 2032 show_count_warnings_stmt.0 */
		0b010000000000000000000, /* Rule number: 2033 show_count_errors_stmt.0 */
		0b000000000000000000010, /* Rule number: 2034 show_warnings_stmt.0 */
		0b000000000000000001000, /* Rule number: 2035 show_errors_stmt.0 */
		0b000000001000000000000, /* Rule number: 2036 show_profiles_stmt.0 */
		0b000000000001000000000, /* Rule number: 2037 show_profile_stmt.0 */
		0b010000000000000000000, /* Rule number: 2038 show_status_stmt.0 */
		0b000000100000000000000, /* Rule number: 2039 show_processlist_stmt.0 */
		0b000000000000100000000, /* Rule number: 2040 show_variables_stmt.0 */
		0b000000000000000000100, /* Rule number: 2041 show_character_set_stmt.0 */
		0b000000000000000010000, /* Rule number: 2042 show_collation_stmt.0 */
		0b000000000010000000000, /* Rule number: 2043 show_privileges_stmt.0 */
		0b000000000000000000001, /* Rule number: 2044 show_grants_stmt.0 */
		0b010000000000000000000, /* Rule number: 2045 show_grants_stmt.1 */
		0b000000000000000000100, /* Rule number: 2046 show_grants_stmt.2 */
		0b000000000000000010000, /* Rule number: 2047 show_create_database_stmt.0 */
		0b000100000000000000000, /* Rule number: 2048 show_create_table_stmt.0 */
		0b000100000000000000000, /* Rule number: 2049 show_create_view_stmt.0 */
		0b000000000100000000000, /* Rule number: 2050 show_binary_log_status_stmt.0 */
		0b000000000000100000000, /* Rule number: 2051 show_replica_status_stmt.0 */
		0b000000000000000010000, /* Rule number: 2052 show_create_procedure_stmt.0 */
		0b000001000000000000000, /* Rule number: 2053 show_create_function_stmt.0 */
		0b000000000000000010000, /* Rule number: 2054 show_create_trigger_stmt.0 */
		0b000000000000000100000, /* Rule number: 2055 show_procedure_status_stmt.0 */
		0b000010000000000000000, /* Rule number: 2056 show_function_status_stmt.0 */
		0b010000000000000000000, /* Rule number: 2057 show_procedure_code_stmt.0 */
		0b000000010000000000000, /* Rule number: 2058 show_function_code_stmt.0 */
		0b000000000000000000010, /* Rule number: 2059 show_create_event_stmt.0 */
		0b000000000100000000000, /* Rule number: 2060 show_create_user_stmt.0 */
		0b000000000000000000010, /* Rule number: 2061 show_parse_tree_stmt.0 */
		0b000000001000000000000, /* Rule number: 2062 engine_or_all.0 */
		0b000000000000010000000, /* Rule number: 2063 engine_or_all.1 */
		0b000000000000000010000, /* Rule number: 2064 opt_storage.0 */
		0b000000000000000000001, /* Rule number: 2065 opt_storage.1 */
		0b000000000000001000000, /* Rule number: 2066 opt_db.0 */
		0b000000000000000000001, /* Rule number: 2067 opt_db.1 */
		0b000000000100000000000, /* Rule number: 2068 opt_full.0 */
		0b000000000000001000000, /* Rule number: 2069 opt_full.1 */
		0b000000000000000000100, /* Rule number: 2070 opt_extended.0 */
		0b000000000000000010000, /* Rule number: 2071 opt_extended.1 */
		0b000000000000000001000, /* Rule number: 2072 opt_show_cmd_type.0 */
		0b000001000000000000000, /* Rule number: 2073 opt_show_cmd_type.1 */
		0b100000000000000000000, /* Rule number: 2074 opt_show_cmd_type.2 */
		0b001000000000000000000, /* Rule number: 2075 opt_show_cmd_type.3 */
		0b100000000000000000000, /* Rule number: 2076 from_or_in.0 */
		0b000000010000000000000, /* Rule number: 2077 from_or_in.1 */
		0b000000000001000000000, /* Rule number: 2078 opt_binlog_in.0 */
		0b000000000000000100000, /* Rule number: 2079 opt_binlog_in.1 */
		0b000000000010000000000, /* Rule number: 2080 binlog_from.0 */
		0b000000000000000000100, /* Rule number: 2081 binlog_from.1 */
		0b000000000000000000010, /* Rule number: 2082 opt_wild_or_where.0 */
		0b000100000000000000000, /* Rule number: 2083 opt_wild_or_where.1 */
		0b000000010000000000000, /* Rule number: 2084 opt_wild_or_where.2 */
		0b000000001000000000000, /* Rule number: 2085 describe_stmt.0 */
		0b000000000000000000010, /* Rule number: 2086 explain_stmt.0 */
		0b000000000001000000000, /* Rule number: 2087 explainable_stmt.0 */
		0b000000000000000000100, /* Rule number: 2088 explainable_stmt.1 */
		0b100000000000000000000, /* Rule number: 2089 explainable_stmt.2 */
		0b000001000000000000000, /* Rule number: 2090 explainable_stmt.3 */
		0b000000000001000000000, /* Rule number: 2091 explainable_stmt.4 */
		0b100000000000000000000, /* Rule number: 2092 explainable_stmt.5 */
		0b000000000000000000010, /* Rule number: 2093 describe_command.0 */
		0b010000000000000000000, /* Rule number: 2094 describe_command.1 */
		0b000000000000000000001, /* Rule number: 2095 opt_explain_format.0 */
		0b000000100000000000000, /* Rule number: 2096 opt_explain_format.1 */
		0b000000000000000000010, /* Rule number: 2097 opt_explain_options.0 */
		0b000000000000000001000, /* Rule number: 2098 opt_explain_options.1 */
		0b100000000000000000000, /* Rule number: 2099 opt_explain_into.0 */
		0b000000000000000100000, /* Rule number: 2100 opt_explain_into.1 */
		0b000000000010000000000, /* Rule number: 2101 opt_explain_for_schema.0 */
		0b000010000000000000000, /* Rule number: 2102 opt_explain_for_schema.1 */
		0b010000000000000000000, /* Rule number: 2103 opt_describe_column.0 */
		0b000000000000100000000, /* Rule number: 2104 opt_describe_column.1 */
		0b000000000000001000000, /* Rule number: 2105 opt_describe_column.2 */
		0b000000000010000000000, /* Rule number: 2106 $@46 */
		0b000000000010000000000, /* Rule number: 2107 flush.0 */
		0b000000000000000000100, /* Rule number: 2108 $@47 */
		0b000000000000000000010, /* Rule number: 2109 flush_options.0 */
		0b000000001000000000000, /* Rule number: 2110 flush_options.1 */
		0b000000010000000000000, /* Rule number: 2111 $@48 */
		0b000000000000010000000, /* Rule number: 2112 opt_flush_lock.0 */
		0b000000000000000000001, /* Rule number: 2113 opt_flush_lock.1 */
		0b100000000000000000000, /* Rule number: 2114 opt_flush_lock.2 */
		0b000000000000001000000, /* Rule number: 2115 flush_options_list.0 */
		0b010000000000000000000, /* Rule number: 2116 flush_options_list.1 */
		0b000100000000000000000, /* Rule number: 2117 flush_option.0 */
		0b000000100000000000000, /* Rule number: 2118 flush_option.1 */
		0b100000000000000000000, /* Rule number: 2119 flush_option.2 */
		0b000000000000000000100, /* Rule number: 2120 flush_option.3 */
		0b000000000010000000000, /* Rule number: 2121 flush_option.4 */
		0b000010000000000000000, /* Rule number: 2122 flush_option.5 */
		0b000000000000100000000, /* Rule number: 2123 flush_option.6 */
		0b000010000000000000000, /* Rule number: 2124 flush_option.7 */
		0b000000010000000000000, /* Rule number: 2125 flush_option.8 */
		0b000010000000000000000, /* Rule number: 2126 flush_option.9 */
		0b010000000000000000000, /* Rule number: 2127 flush_option.10 */
		0b000000000000000000100, /* Rule number: 2128 opt_table_list.0 */
		0b000000010000000000000, /* Rule number: 2129 opt_table_list.1 */
		0b000000000000100000000, /* Rule number: 2130 $@49 */
		0b000000001000000000000, /* Rule number: 2131 reset.0 */
		0b000000000000000100000, /* Rule number: 2132 reset.1 */
		0b000000000000100000000, /* Rule number: 2133 reset_options.0 */
		0b000000000000100000000, /* Rule number: 2134 reset_options.1 */
		0b000000000000010000000, /* Rule number: 2135 opt_if_exists_ident.0 */
		0b000000000001000000000, /* Rule number: 2136 opt_if_exists_ident.1 */
		0b000100000000000000000, /* Rule number: 2137 persisted_variable_ident.0 */
		0b000000100000000000000, /* Rule number: 2138 persisted_variable_ident.1 */
		0b100000000000000000000, /* Rule number: 2139 persisted_variable_ident.2 */
		0b000000000000010000000, /* Rule number: 2140 $@50 */
		0b100000000000000000000, /* Rule number: 2141 $@51 */
		0b000000000100000000000, /* Rule number: 2142 reset_option.0 */
		0b000000000010000000000, /* Rule number: 2143 reset_option.1 */
		0b000000000100000000000, /* Rule number: 2144 opt_replica_reset_options.0 */
		0b000000000010000000000, /* Rule number: 2145 opt_replica_reset_options.1 */
		0b000000000000000001000, /* Rule number: 2146 source_reset_options.0 */
		0b000000000000100000000, /* Rule number: 2147 source_reset_options.1 */
		0b000000000000010000000, /* Rule number: 2148 $@52 */
		0b000000000000010000000, /* Rule number: 2149 purge.0 */
		0b000000000000010000000, /* Rule number: 2150 purge_options.0 */
		0b000000000000000001000, /* Rule number: 2151 purge_option.0 */
		0b000010000000000000000, /* Rule number: 2152 purge_option.1 */
		0b000000000100000000000, /* Rule number: 2153 kill.0 */
		0b000001000000000000000, /* Rule number: 2154 kill_option.0 */
		0b000001000000000000000, /* Rule number: 2155 kill_option.1 */
		0b000000000000010000000, /* Rule number: 2156 kill_option.2 */
		0b100000000000000000000, /* Rule number: 2157 use.0 */
		0b000000000000010000000, /* Rule number: 2158 load_stmt.0 */
		0b000000001000000000000, /* Rule number: 2159 data_or_xml.0 */
		0b000100000000000000000, /* Rule number: 2160 data_or_xml.1 */
		0b000000000000000001000, /* Rule number: 2161 opt_local.0 */
		0b000000000010000000000, /* Rule number: 2162 opt_local.1 */
		0b000000000100000000000, /* Rule number: 2163 opt_from_keyword.0 */
		0b000000100000000000000, /* Rule number: 2164 opt_from_keyword.1 */
		0b000000000000001000000, /* Rule number: 2165 load_data_lock.0 */
		0b000000010000000000000, /* Rule number: 2166 load_data_lock.1 */
		0b000000010000000000000, /* Rule number: 2167 load_data_lock.2 */
		0b000000000010000000000, /* Rule number: 2168 load_source_type.0 */
		0b000000000000000001000, /* Rule number: 2169 load_source_type.1 */
		0b000000000000000001000, /* Rule number: 2170 load_source_type.2 */
		0b000000000000000010000, /* Rule number: 2171 opt_source_count.0 */
		0b000000000000100000000, /* Rule number: 2172 opt_source_count.1 */
		0b010000000000000000000, /* Rule number: 2173 opt_source_order.0 */
		0b000000000000010000000, /* Rule number: 2174 opt_source_order.1 */
		0b000000010000000000000, /* Rule number: 2175 opt_duplicate.0 */
		0b100000000000000000000, /* Rule number: 2176 opt_duplicate.1 */
		0b000000000000010000000, /* Rule number: 2177 duplicate.0 */
		0b010000000000000000000, /* Rule number: 2178 duplicate.1 */
		0b000000000000100000000, /* Rule number: 2179 opt_field_term.0 */
		0b010000000000000000000, /* Rule number: 2180 opt_field_term.1 */
		0b000000000000000010000, /* Rule number: 2181 field_term_list.0 */
		0b000000000100000000000, /* Rule number: 2182 field_term_list.1 */
		0b000000000000100000000, /* Rule number: 2183 field_term.0 */
		0b000000000000000010000, /* Rule number: 2184 field_term.1 */
		0b000100000000000000000, /* Rule number: 2185 field_term.2 */
		0b000000000000000000001, /* Rule number: 2186 field_term.3 */
		0b000000000000100000000, /* Rule number: 2187 opt_line_term.0 */
		0b000000010000000000000, /* Rule number: 2188 opt_line_term.1 */
		0b000000000000001000000, /* Rule number: 2189 line_term_list.0 */
		0b000000000000000100000, /* Rule number: 2190 line_term_list.1 */
		0b000000010000000000000, /* Rule number: 2191 line_term.0 */
		0b000000010000000000000, /* Rule number: 2192 line_term.1 */
		0b010000000000000000000, /* Rule number: 2193 opt_xml_rows_identified_by.0 */
		0b000000000000010000000, /* Rule number: 2194 opt_xml_rows_identified_by.1 */
		0b100000000000000000000, /* Rule number: 2195 opt_ignore_lines.0 */
		0b000000000000000000010, /* Rule number: 2196 opt_ignore_lines.1 */
		0b000001000000000000000, /* Rule number: 2197 lines_or_rows.0 */
		0b000000010000000000000, /* Rule number: 2198 lines_or_rows.1 */
		0b000000001000000000000, /* Rule number: 2199 opt_field_or_var_spec.0 */
		0b000000000000000010000, /* Rule number: 2200 opt_field_or_var_spec.1 */
		0b000000000001000000000, /* Rule number: 2201 opt_field_or_var_spec.2 */
		0b000000001000000000000, /* Rule number: 2202 fields_or_vars.0 */
		0b000000000010000000000, /* Rule number: 2203 fields_or_vars.1 */
		0b000000000000001000000, /* Rule number: 2204 field_or_var.0 */
		0b000000000000100000000, /* Rule number: 2205 field_or_var.1 */
		0b000000000000000000010, /* Rule number: 2206 opt_load_data_set_spec.0 */
		0b010000000000000000000, /* Rule number: 2207 opt_load_data_set_spec.1 */
		0b000000000000000001000, /* Rule number: 2208 load_data_set_list.0 */
		0b000010000000000000000, /* Rule number: 2209 load_data_set_list.1 */
		0b000010000000000000000, /* Rule number: 2210 load_data_set_elem.0 */
		0b000000001000000000000, /* Rule number: 2211 opt_load_algorithm.0 */
		0b000100000000000000000, /* Rule number: 2212 opt_load_algorithm.1 */
		0b000000000001000000000, /* Rule number: 2213 opt_compression_algorithm.0 */
		0b000000000000000000100, /* Rule number: 2214 opt_compression_algorithm.1 */
		0b100000000000000000000, /* Rule number: 2215 opt_load_parallel.0 */
		0b000000000100000000000, /* Rule number: 2216 opt_load_parallel.1 */
		0b100000000000000000000, /* Rule number: 2217 opt_load_memory.0 */
		0b100000000000000000000, /* Rule number: 2218 opt_load_memory.1 */
		0b000000000010000000000, /* Rule number: 2219 text_literal.0 */
		0b000000000000000100000, /* Rule number: 2220 text_literal.1 */
		0b000000000000001000000, /* Rule number: 2221 text_literal.2 */
		0b000000000000000000100, /* Rule number: 2222 text_literal.3 */
		0b000000000000100000000, /* Rule number: 2223 text_string.0 */
		0b000000000000100000000, /* Rule number: 2224 text_string.1 */
		0b000000010000000000000, /* Rule number: 2225 text_string.2 */
		0b000000000100000000000, /* Rule number: 2226 param_marker.0 */
		0b000000000000001000000, /* Rule number: 2227 signed_literal.0 */
		0b000000000000000000001, /* Rule number: 2228 signed_literal.1 */
		0b000000010000000000000, /* Rule number: 2229 signed_literal.2 */
		0b000000001000000000000, /* Rule number: 2230 signed_literal_or_null.0 */
		0b000000000000010000000, /* Rule number: 2231 signed_literal_or_null.1 */
		0b000100000000000000000, /* Rule number: 2232 null_as_literal.0 */
		0b001000000000000000000, /* Rule number: 2233 literal.0 */
		0b000000000010000000000, /* Rule number: 2234 literal.1 */
		0b000000000000000000100, /* Rule number: 2235 literal.2 */
		0b100000000000000000000, /* Rule number: 2236 literal.3 */
		0b000000000000100000000, /* Rule number: 2237 literal.4 */
		0b000000000000000001000, /* Rule number: 2238 literal.5 */
		0b001000000000000000000, /* Rule number: 2239 literal.6 */
		0b000000000000000000010, /* Rule number: 2240 literal.7 */
		0b000000000010000000000, /* Rule number: 2241 literal.8 */
		0b000000000000000000010, /* Rule number: 2242 literal_or_null.0 */
		0b000000000000000010000, /* Rule number: 2243 literal_or_null.1 */
		0b000000000100000000000, /* Rule number: 2244 NUM_literal.0 */
		0b000000000000000010000, /* Rule number: 2245 NUM_literal.1 */
		0b000000100000000000000, /* Rule number: 2246 NUM_literal.2 */
		0b001000000000000000000, /* Rule number: 2247 int64_literal.0 */
		0b000000000000000000001, /* Rule number: 2248 int64_literal.1 */
		0b000010000000000000000, /* Rule number: 2249 int64_literal.2 */
		0b000000000000000001000, /* Rule number: 2250 temporal_literal.0 */
		0b000010000000000000000, /* Rule number: 2251 temporal_literal.1 */
		0b000000000000000000100, /* Rule number: 2252 temporal_literal.2 */
		0b000000100000000000000, /* Rule number: 2253 opt_interval.0 */
		0b000000000000000000001, /* Rule number: 2254 opt_interval.1 */
		0b000000000100000000000, /* Rule number: 2255 insert_column.0 */
		0b000001000000000000000, /* Rule number: 2256 table_wild.0 */
		0b000010000000000000000, /* Rule number: 2257 table_wild.1 */
		0b000000000000000010000, /* Rule number: 2258 order_expr.0 */
		0b000000000000000100000, /* Rule number: 2259 grouping_expr.0 */
		0b000000000001000000000, /* Rule number: 2260 simple_ident.0 */
		0b000001000000000000000, /* Rule number: 2261 simple_ident.1 */
		0b000000000001000000000, /* Rule number: 2262 simple_ident_nospvar.0 */
		0b000000000100000000000, /* Rule number: 2263 simple_ident_nospvar.1 */
		0b000100000000000000000, /* Rule number: 2264 simple_ident_q.0 */
		0b000000000000001000000, /* Rule number: 2265 simple_ident_q.1 */
		0b000000010000000000000, /* Rule number: 2266 table_ident.0 */
		0b000000000010000000000, /* Rule number: 2267 table_ident.1 */
		0b000000000000001000000, /* Rule number: 2268 table_ident_opt_wild.0 */
		0b000000010000000000000, /* Rule number: 2269 table_ident_opt_wild.1 */
		0b000001000000000000000, /* Rule number: 2270 IDENT_sys.0 */
		0b000001000000000000000, /* Rule number: 2271 IDENT_sys.1 */
		0b100000000000000000000, /* Rule number: 2272 TEXT_STRING_sys_nonewline.0 */
		0b100000000000000000000, /* Rule number: 2273 filter_wild_db_table_string.0 */
		0b000000000010000000000, /* Rule number: 2274 TEXT_STRING_sys.0 */
		0b000000000000010000000, /* Rule number: 2275 TEXT_STRING_literal.0 */
		0b000000000001000000000, /* Rule number: 2276 TEXT_STRING_filesystem.0 */
		0b000000000000000000010, /* Rule number: 2277 TEXT_STRING_password.0 */
		0b000000000010000000000, /* Rule number: 2278 TEXT_STRING_hash.0 */
		0b000000000000000100000, /* Rule number: 2279 TEXT_STRING_hash.1 */
		0b000000000000000010000, /* Rule number: 2280 TEXT_STRING_validated.0 */
		0b000000000000000000001, /* Rule number: 2281 ident.0 */
		0b000000000010000000000, /* Rule number: 2282 ident.1 */
		0b001000000000000000000, /* Rule number: 2283 role_ident.0 */
		0b100000000000000000000, /* Rule number: 2284 role_ident.1 */
		0b000000000000100000000, /* Rule number: 2285 label_ident.0 */
		0b000000100000000000000, /* Rule number: 2286 label_ident.1 */
		0b010000000000000000000, /* Rule number: 2287 lvalue_ident.0 */
		0b000000100000000000000, /* Rule number: 2288 lvalue_ident.1 */
		0b000000000000000100000, /* Rule number: 2289 ident_or_text.0 */
		0b000000000000000100000, /* Rule number: 2290 ident_or_text.1 */
		0b000000000000000000001, /* Rule number: 2291 ident_or_text.2 */
		0b000000010000000000000, /* Rule number: 2292 role_ident_or_text.0 */
		0b000000000000000000010, /* Rule number: 2293 role_ident_or_text.1 */
		0b000000000000001000000, /* Rule number: 2294 role_ident_or_text.2 */
		0b000000000000000100000, /* Rule number: 2295 user_ident_or_text.0 */
		0b000010000000000000000, /* Rule number: 2296 user_ident_or_text.1 */
		0b000000000000010000000, /* Rule number: 2297 user.0 */
		0b000000100000000000000, /* Rule number: 2298 user.1 */
		0b000000001000000000000, /* Rule number: 2299 role.0 */
		0b000000000000000001000, /* Rule number: 2300 role.1 */
		0b000000000000010000000, /* Rule number: 2301 schema.0 */
		0b000000000000000000010, /* Rule number: 2302 ident_keyword.0 */
		0b001000000000000000000, /* Rule number: 2303 ident_keyword.1 */
		0b000000000010000000000, /* Rule number: 2304 ident_keyword.2 */
		0b000000001000000000000, /* Rule number: 2305 ident_keyword.3 */
		0b000000000000000000100, /* Rule number: 2306 ident_keyword.4 */
		0b000000000000000001000, /* Rule number: 2307 ident_keywords_ambiguous_1_roles_and_labels.0 */
		0b000000000000000100000, /* Rule number: 2308 ident_keywords_ambiguous_1_roles_and_labels.1 */
		0b000000000000000000010, /* Rule number: 2309 ident_keywords_ambiguous_1_roles_and_labels.2 */
		0b000000000000000010000, /* Rule number: 2310 ident_keywords_ambiguous_2_labels.0 */
		0b100000000000000000000, /* Rule number: 2311 ident_keywords_ambiguous_2_labels.1 */
		0b000010000000000000000, /* Rule number: 2312 ident_keywords_ambiguous_2_labels.2 */
		0b000000000000001000000, /* Rule number: 2313 ident_keywords_ambiguous_2_labels.3 */
		0b000000000010000000000, /* Rule number: 2314 ident_keywords_ambiguous_2_labels.4 */
		0b000001000000000000000, /* Rule number: 2315 ident_keywords_ambiguous_2_labels.5 */
		0b000000000000000100000, /* Rule number: 2316 ident_keywords_ambiguous_2_labels.6 */
		0b100000000000000000000, /* Rule number: 2317 ident_keywords_ambiguous_2_labels.7 */
		0b000000001000000000000, /* Rule number: 2318 ident_keywords_ambiguous_2_labels.8 */
		0b000000000100000000000, /* Rule number: 2319 ident_keywords_ambiguous_2_labels.9 */
		0b000100000000000000000, /* Rule number: 2320 ident_keywords_ambiguous_2_labels.10 */
		0b000000000000000100000, /* Rule number: 2321 ident_keywords_ambiguous_2_labels.11 */
		0b000000100000000000000, /* Rule number: 2322 ident_keywords_ambiguous_2_labels.12 */
		0b000010000000000000000, /* Rule number: 2323 ident_keywords_ambiguous_2_labels.13 */
		0b000000010000000000000, /* Rule number: 2324 ident_keywords_ambiguous_2_labels.14 */
		0b000010000000000000000, /* Rule number: 2325 ident_keywords_ambiguous_2_labels.15 */
		0b000000000100000000000, /* Rule number: 2326 ident_keywords_ambiguous_2_labels.16 */
		0b000100000000000000000, /* Rule number: 2327 ident_keywords_ambiguous_2_labels.17 */
		0b000000000000001000000, /* Rule number: 2328 ident_keywords_ambiguous_2_labels.18 */
		0b000000000000000000100, /* Rule number: 2329 ident_keywords_ambiguous_2_labels.19 */
		0b001000000000000000000, /* Rule number: 2330 ident_keywords_ambiguous_2_labels.20 */
		0b000000100000000000000, /* Rule number: 2331 ident_keywords_ambiguous_2_labels.21 */
		0b010000000000000000000, /* Rule number: 2332 ident_keywords_ambiguous_2_labels.22 */
		0b000000000000001000000, /* Rule number: 2333 ident_keywords_ambiguous_2_labels.23 */
		0b000100000000000000000, /* Rule number: 2334 ident_keywords_ambiguous_2_labels.24 */
		0b000000000000000000001, /* Rule number: 2335 ident_keywords_ambiguous_2_labels.25 */
		0b000000000001000000000, /* Rule number: 2336 ident_keywords_ambiguous_2_labels.26 */
		0b000000000000000000100, /* Rule number: 2337 ident_keywords_ambiguous_2_labels.27 */
		0b000000000100000000000, /* Rule number: 2338 ident_keywords_ambiguous_2_labels.28 */
		0b000000000000001000000, /* Rule number: 2339 ident_keywords_ambiguous_2_labels.29 */
		0b010000000000000000000, /* Rule number: 2340 ident_keywords_ambiguous_2_labels.30 */
		0b000000010000000000000, /* Rule number: 2341 ident_keywords_ambiguous_2_labels.31 */
		0b100000000000000000000, /* Rule number: 2342 ident_keywords_ambiguous_2_labels.32 */
		0b000000000000000000010, /* Rule number: 2343 ident_keywords_ambiguous_2_labels.33 */
		0b000000010000000000000, /* Rule number: 2344 ident_keywords_ambiguous_2_labels.34 */
		0b001000000000000000000, /* Rule number: 2345 label_keyword.0 */
		0b000000000000001000000, /* Rule number: 2346 label_keyword.1 */
		0b000000000010000000000, /* Rule number: 2347 label_keyword.2 */
		0b000000001000000000000, /* Rule number: 2348 ident_keywords_ambiguous_3_roles.0 */
		0b000000000100000000000, /* Rule number: 2349 ident_keywords_ambiguous_3_roles.1 */
		0b000000000000000000010, /* Rule number: 2350 ident_keywords_ambiguous_3_roles.2 */
		0b100000000000000000000, /* Rule number: 2351 ident_keywords_ambiguous_3_roles.3 */
		0b000000000000000000010, /* Rule number: 2352 ident_keywords_ambiguous_3_roles.4 */
		0b000000000000000000100, /* Rule number: 2353 ident_keywords_ambiguous_3_roles.5 */
		0b000000000000000100000, /* Rule number: 2354 ident_keywords_ambiguous_3_roles.6 */
		0b000000000010000000000, /* Rule number: 2355 ident_keywords_ambiguous_3_roles.7 */
		0b000000000010000000000, /* Rule number: 2356 ident_keywords_ambiguous_3_roles.8 */
		0b000010000000000000000, /* Rule number: 2357 ident_keywords_unambiguous.0 */
		0b000000100000000000000, /* Rule number: 2358 ident_keywords_unambiguous.1 */
		0b000000100000000000000, /* Rule number: 2359 ident_keywords_unambiguous.2 */
		0b000000001000000000000, /* Rule number: 2360 ident_keywords_unambiguous.3 */
		0b000000010000000000000, /* Rule number: 2361 ident_keywords_unambiguous.4 */
		0b000000000000001000000, /* Rule number: 2362 ident_keywords_unambiguous.5 */
		0b100000000000000000000, /* Rule number: 2363 ident_keywords_unambiguous.6 */
		0b000010000000000000000, /* Rule number: 2364 ident_keywords_unambiguous.7 */
		0b000010000000000000000, /* Rule number: 2365 ident_keywords_unambiguous.8 */
		0b000000000000100000000, /* Rule number: 2366 ident_keywords_unambiguous.9 */
		0b000000000000000000010, /* Rule number: 2367 ident_keywords_unambiguous.10 */
		0b000000000000100000000, /* Rule number: 2368 ident_keywords_unambiguous.11 */
		0b000000000000000010000, /* Rule number: 2369 ident_keywords_unambiguous.12 */
		0b000100000000000000000, /* Rule number: 2370 ident_keywords_unambiguous.13 */
		0b000000000000000000010, /* Rule number: 2371 ident_keywords_unambiguous.14 */
		0b000000000000000000001, /* Rule number: 2372 ident_keywords_unambiguous.15 */
		0b000000000100000000000, /* Rule number: 2373 ident_keywords_unambiguous.16 */
		0b000001000000000000000, /* Rule number: 2374 ident_keywords_unambiguous.17 */
		0b000000000000010000000, /* Rule number: 2375 ident_keywords_unambiguous.18 */
		0b010000000000000000000, /* Rule number: 2376 ident_keywords_unambiguous.19 */
		0b000000000000100000000, /* Rule number: 2377 ident_keywords_unambiguous.20 */
		0b000001000000000000000, /* Rule number: 2378 ident_keywords_unambiguous.21 */
		0b000001000000000000000, /* Rule number: 2379 ident_keywords_unambiguous.22 */
		0b000000000000000100000, /* Rule number: 2380 ident_keywords_unambiguous.23 */
		0b100000000000000000000, /* Rule number: 2381 ident_keywords_unambiguous.24 */
		0b000000000010000000000, /* Rule number: 2382 ident_keywords_unambiguous.25 */
		0b000010000000000000000, /* Rule number: 2383 ident_keywords_unambiguous.26 */
		0b010000000000000000000, /* Rule number: 2384 ident_keywords_unambiguous.27 */
		0b000000000000001000000, /* Rule number: 2385 ident_keywords_unambiguous.28 */
		0b000000010000000000000, /* Rule number: 2386 ident_keywords_unambiguous.29 */
		0b000000000000000001000, /* Rule number: 2387 ident_keywords_unambiguous.30 */
		0b100000000000000000000, /* Rule number: 2388 ident_keywords_unambiguous.31 */
		0b000000000000000001000, /* Rule number: 2389 ident_keywords_unambiguous.32 */
		0b100000000000000000000, /* Rule number: 2390 ident_keywords_unambiguous.33 */
		0b001000000000000000000, /* Rule number: 2391 ident_keywords_unambiguous.34 */
		0b000000000001000000000, /* Rule number: 2392 ident_keywords_unambiguous.35 */
		0b001000000000000000000, /* Rule number: 2393 ident_keywords_unambiguous.36 */
		0b000000000000000100000, /* Rule number: 2394 ident_keywords_unambiguous.37 */
		0b000000000000000001000, /* Rule number: 2395 ident_keywords_unambiguous.38 */
		0b000000000000000001000, /* Rule number: 2396 ident_keywords_unambiguous.39 */
		0b000000000000000010000, /* Rule number: 2397 ident_keywords_unambiguous.40 */
		0b000000000000000100000, /* Rule number: 2398 ident_keywords_unambiguous.41 */
		0b000001000000000000000, /* Rule number: 2399 ident_keywords_unambiguous.42 */
		0b000000000000000000001, /* Rule number: 2400 ident_keywords_unambiguous.43 */
		0b000000000010000000000, /* Rule number: 2401 ident_keywords_unambiguous.44 */
		0b000000000000000010000, /* Rule number: 2402 ident_keywords_unambiguous.45 */
		0b000000000010000000000, /* Rule number: 2403 ident_keywords_unambiguous.46 */
		0b000000100000000000000, /* Rule number: 2404 ident_keywords_unambiguous.47 */
		0b010000000000000000000, /* Rule number: 2405 ident_keywords_unambiguous.48 */
		0b000000000000001000000, /* Rule number: 2406 ident_keywords_unambiguous.49 */
		0b000000000000000001000, /* Rule number: 2407 ident_keywords_unambiguous.50 */
		0b000000000000000000010, /* Rule number: 2408 ident_keywords_unambiguous.51 */
		0b000000000000010000000, /* Rule number: 2409 ident_keywords_unambiguous.52 */
		0b000000000000000000001, /* Rule number: 2410 ident_keywords_unambiguous.53 */
		0b000001000000000000000, /* Rule number: 2411 ident_keywords_unambiguous.54 */
		0b000000100000000000000, /* Rule number: 2412 ident_keywords_unambiguous.55 */
		0b000000000000000100000, /* Rule number: 2413 ident_keywords_unambiguous.56 */
		0b000000000000000000010, /* Rule number: 2414 ident_keywords_unambiguous.57 */
		0b000100000000000000000, /* Rule number: 2415 ident_keywords_unambiguous.58 */
		0b000000000000100000000, /* Rule number: 2416 ident_keywords_unambiguous.59 */
		0b000000000000000100000, /* Rule number: 2417 ident_keywords_unambiguous.60 */
		0b000000000000100000000, /* Rule number: 2418 ident_keywords_unambiguous.61 */
		0b000010000000000000000, /* Rule number: 2419 ident_keywords_unambiguous.62 */
		0b000000000001000000000, /* Rule number: 2420 ident_keywords_unambiguous.63 */
		0b000000000000000010000, /* Rule number: 2421 ident_keywords_unambiguous.64 */
		0b000000000001000000000, /* Rule number: 2422 ident_keywords_unambiguous.65 */
		0b000000000000000000001, /* Rule number: 2423 ident_keywords_unambiguous.66 */
		0b000000000000000001000, /* Rule number: 2424 ident_keywords_unambiguous.67 */
		0b000000010000000000000, /* Rule number: 2425 ident_keywords_unambiguous.68 */
		0b000000000000000001000, /* Rule number: 2426 ident_keywords_unambiguous.69 */
		0b000000000001000000000, /* Rule number: 2427 ident_keywords_unambiguous.70 */
		0b000000000000000010000, /* Rule number: 2428 ident_keywords_unambiguous.71 */
		0b000000000000000001000, /* Rule number: 2429 ident_keywords_unambiguous.72 */
		0b000000000000000000100, /* Rule number: 2430 ident_keywords_unambiguous.73 */
		0b000000000100000000000, /* Rule number: 2431 ident_keywords_unambiguous.74 */
		0b000000000010000000000, /* Rule number: 2432 ident_keywords_unambiguous.75 */
		0b000000000010000000000, /* Rule number: 2433 ident_keywords_unambiguous.76 */
		0b000000000000100000000, /* Rule number: 2434 ident_keywords_unambiguous.77 */
		0b000000000000000000010, /* Rule number: 2435 ident_keywords_unambiguous.78 */
		0b000010000000000000000, /* Rule number: 2436 ident_keywords_unambiguous.79 */
		0b000000000000000001000, /* Rule number: 2437 ident_keywords_unambiguous.80 */
		0b000000000000000001000, /* Rule number: 2438 ident_keywords_unambiguous.81 */
		0b010000000000000000000, /* Rule number: 2439 ident_keywords_unambiguous.82 */
		0b000000010000000000000, /* Rule number: 2440 ident_keywords_unambiguous.83 */
		0b001000000000000000000, /* Rule number: 2441 ident_keywords_unambiguous.84 */
		0b100000000000000000000, /* Rule number: 2442 ident_keywords_unambiguous.85 */
		0b000000000000000000010, /* Rule number: 2443 ident_keywords_unambiguous.86 */
		0b000000000010000000000, /* Rule number: 2444 ident_keywords_unambiguous.87 */
		0b000000000000000000100, /* Rule number: 2445 ident_keywords_unambiguous.88 */
		0b000000000000000001000, /* Rule number: 2446 ident_keywords_unambiguous.89 */
		0b000000001000000000000, /* Rule number: 2447 ident_keywords_unambiguous.90 */
		0b100000000000000000000, /* Rule number: 2448 ident_keywords_unambiguous.91 */
		0b100000000000000000000, /* Rule number: 2449 ident_keywords_unambiguous.92 */
		0b000000000000000000100, /* Rule number: 2450 ident_keywords_unambiguous.93 */
		0b000000000001000000000, /* Rule number: 2451 ident_keywords_unambiguous.94 */
		0b000000000000000000010, /* Rule number: 2452 ident_keywords_unambiguous.95 */
		0b100000000000000000000, /* Rule number: 2453 ident_keywords_unambiguous.96 */
		0b000000000010000000000, /* Rule number: 2454 ident_keywords_unambiguous.97 */
		0b000000000000000100000, /* Rule number: 2455 ident_keywords_unambiguous.98 */
		0b100000000000000000000, /* Rule number: 2456 ident_keywords_unambiguous.99 */
		0b000000100000000000000, /* Rule number: 2457 ident_keywords_unambiguous.100 */
		0b000000000000000010000, /* Rule number: 2458 ident_keywords_unambiguous.101 */
		0b000000000000000000001, /* Rule number: 2459 ident_keywords_unambiguous.102 */
		0b000000000010000000000, /* Rule number: 2460 ident_keywords_unambiguous.103 */
		0b000010000000000000000, /* Rule number: 2461 ident_keywords_unambiguous.104 */
		0b000000000000001000000, /* Rule number: 2462 ident_keywords_unambiguous.105 */
		0b000100000000000000000, /* Rule number: 2463 ident_keywords_unambiguous.106 */
		0b000000000000000000100, /* Rule number: 2464 ident_keywords_unambiguous.107 */
		0b000001000000000000000, /* Rule number: 2465 ident_keywords_unambiguous.108 */
		0b000000001000000000000, /* Rule number: 2466 ident_keywords_unambiguous.109 */
		0b000100000000000000000, /* Rule number: 2467 ident_keywords_unambiguous.110 */
		0b000000010000000000000, /* Rule number: 2468 ident_keywords_unambiguous.111 */
		0b100000000000000000000, /* Rule number: 2469 ident_keywords_unambiguous.112 */
		0b000000000000000100000, /* Rule number: 2470 ident_keywords_unambiguous.113 */
		0b000000000000000100000, /* Rule number: 2471 ident_keywords_unambiguous.114 */
		0b000000000010000000000, /* Rule number: 2472 ident_keywords_unambiguous.115 */
		0b000000100000000000000, /* Rule number: 2473 ident_keywords_unambiguous.116 */
		0b000000000000001000000, /* Rule number: 2474 ident_keywords_unambiguous.117 */
		0b000000000001000000000, /* Rule number: 2475 ident_keywords_unambiguous.118 */
		0b000000000001000000000, /* Rule number: 2476 ident_keywords_unambiguous.119 */
		0b000000001000000000000, /* Rule number: 2477 ident_keywords_unambiguous.120 */
		0b000100000000000000000, /* Rule number: 2478 ident_keywords_unambiguous.121 */
		0b000000100000000000000, /* Rule number: 2479 ident_keywords_unambiguous.122 */
		0b000000000100000000000, /* Rule number: 2480 ident_keywords_unambiguous.123 */
		0b000000000000010000000, /* Rule number: 2481 ident_keywords_unambiguous.124 */
		0b000000000000010000000, /* Rule number: 2482 ident_keywords_unambiguous.125 */
		0b000000000000001000000, /* Rule number: 2483 ident_keywords_unambiguous.126 */
		0b000000001000000000000, /* Rule number: 2484 ident_keywords_unambiguous.127 */
		0b000000010000000000000, /* Rule number: 2485 ident_keywords_unambiguous.128 */
		0b000000000000000010000, /* Rule number: 2486 ident_keywords_unambiguous.129 */
		0b000000001000000000000, /* Rule number: 2487 ident_keywords_unambiguous.130 */
		0b000000000000001000000, /* Rule number: 2488 ident_keywords_unambiguous.131 */
		0b000000010000000000000, /* Rule number: 2489 ident_keywords_unambiguous.132 */
		0b000000000000100000000, /* Rule number: 2490 ident_keywords_unambiguous.133 */
		0b000000000000000010000, /* Rule number: 2491 ident_keywords_unambiguous.134 */
		0b000000000000010000000, /* Rule number: 2492 ident_keywords_unambiguous.135 */
		0b000000000100000000000, /* Rule number: 2493 ident_keywords_unambiguous.136 */
		0b000000000010000000000, /* Rule number: 2494 ident_keywords_unambiguous.137 */
		0b000000000000000100000, /* Rule number: 2495 ident_keywords_unambiguous.138 */
		0b000001000000000000000, /* Rule number: 2496 ident_keywords_unambiguous.139 */
		0b001000000000000000000, /* Rule number: 2497 ident_keywords_unambiguous.140 */
		0b000000000000010000000, /* Rule number: 2498 ident_keywords_unambiguous.141 */
		0b000001000000000000000, /* Rule number: 2499 ident_keywords_unambiguous.142 */
		0b000000000001000000000, /* Rule number: 2500 ident_keywords_unambiguous.143 */
		0b000000000000001000000, /* Rule number: 2501 ident_keywords_unambiguous.144 */
		0b000000000001000000000, /* Rule number: 2502 ident_keywords_unambiguous.145 */
		0b000000000000000000010, /* Rule number: 2503 ident_keywords_unambiguous.146 */
		0b000000000000000000100, /* Rule number: 2504 ident_keywords_unambiguous.147 */
		0b000000000001000000000, /* Rule number: 2505 ident_keywords_unambiguous.148 */
		0b000000100000000000000, /* Rule number: 2506 ident_keywords_unambiguous.149 */
		0b000000000000000000001, /* Rule number: 2507 ident_keywords_unambiguous.150 */
		0b001000000000000000000, /* Rule number: 2508 ident_keywords_unambiguous.151 */
		0b000000000000000001000, /* Rule number: 2509 ident_keywords_unambiguous.152 */
		0b000000000000000001000, /* Rule number: 2510 ident_keywords_unambiguous.153 */
		0b000000000010000000000, /* Rule number: 2511 ident_keywords_unambiguous.154 */
		0b000000000000001000000, /* Rule number: 2512 ident_keywords_unambiguous.155 */
		0b000000001000000000000, /* Rule number: 2513 ident_keywords_unambiguous.156 */
		0b000000001000000000000, /* Rule number: 2514 ident_keywords_unambiguous.157 */
		0b000000100000000000000, /* Rule number: 2515 ident_keywords_unambiguous.158 */
		0b000000000000010000000, /* Rule number: 2516 ident_keywords_unambiguous.159 */
		0b001000000000000000000, /* Rule number: 2517 ident_keywords_unambiguous.160 */
		0b000000010000000000000, /* Rule number: 2518 ident_keywords_unambiguous.161 */
		0b000000000000000000100, /* Rule number: 2519 ident_keywords_unambiguous.162 */
		0b000000000000000000010, /* Rule number: 2520 ident_keywords_unambiguous.163 */
		0b000100000000000000000, /* Rule number: 2521 ident_keywords_unambiguous.164 */
		0b000000000000100000000, /* Rule number: 2522 ident_keywords_unambiguous.165 */
		0b010000000000000000000, /* Rule number: 2523 ident_keywords_unambiguous.166 */
		0b000000000000000000001, /* Rule number: 2524 ident_keywords_unambiguous.167 */
		0b000000000000000001000, /* Rule number: 2525 ident_keywords_unambiguous.168 */
		0b000000010000000000000, /* Rule number: 2526 ident_keywords_unambiguous.169 */
		0b000000100000000000000, /* Rule number: 2527 ident_keywords_unambiguous.170 */
		0b000000001000000000000, /* Rule number: 2528 ident_keywords_unambiguous.171 */
		0b000001000000000000000, /* Rule number: 2529 ident_keywords_unambiguous.172 */
		0b000000000000000000010, /* Rule number: 2530 ident_keywords_unambiguous.173 */
		0b000100000000000000000, /* Rule number: 2531 ident_keywords_unambiguous.174 */
		0b000000000000000001000, /* Rule number: 2532 ident_keywords_unambiguous.175 */
		0b000000000000001000000, /* Rule number: 2533 ident_keywords_unambiguous.176 */
		0b000000000000000000100, /* Rule number: 2534 ident_keywords_unambiguous.177 */
		0b000000000000100000000, /* Rule number: 2535 ident_keywords_unambiguous.178 */
		0b000000000000000000010, /* Rule number: 2536 ident_keywords_unambiguous.179 */
		0b000000010000000000000, /* Rule number: 2537 ident_keywords_unambiguous.180 */
		0b000010000000000000000, /* Rule number: 2538 ident_keywords_unambiguous.181 */
		0b000010000000000000000, /* Rule number: 2539 ident_keywords_unambiguous.182 */
		0b000000000000000000010, /* Rule number: 2540 ident_keywords_unambiguous.183 */
		0b000000000000000000100, /* Rule number: 2541 ident_keywords_unambiguous.184 */
		0b000000000000000010000, /* Rule number: 2542 ident_keywords_unambiguous.185 */
		0b100000000000000000000, /* Rule number: 2543 ident_keywords_unambiguous.186 */
		0b100000000000000000000, /* Rule number: 2544 ident_keywords_unambiguous.187 */
		0b000000000000000000100, /* Rule number: 2545 ident_keywords_unambiguous.188 */
		0b000000000000000000001, /* Rule number: 2546 ident_keywords_unambiguous.189 */
		0b000000000000000000100, /* Rule number: 2547 ident_keywords_unambiguous.190 */
		0b000000100000000000000, /* Rule number: 2548 ident_keywords_unambiguous.191 */
		0b000100000000000000000, /* Rule number: 2549 ident_keywords_unambiguous.192 */
		0b000100000000000000000, /* Rule number: 2550 ident_keywords_unambiguous.193 */
		0b000000010000000000000, /* Rule number: 2551 ident_keywords_unambiguous.194 */
		0b000000001000000000000, /* Rule number: 2552 ident_keywords_unambiguous.195 */
		0b000000000000000000100, /* Rule number: 2553 ident_keywords_unambiguous.196 */
		0b000001000000000000000, /* Rule number: 2554 ident_keywords_unambiguous.197 */
		0b000000000000010000000, /* Rule number: 2555 ident_keywords_unambiguous.198 */
		0b000000000000000000010, /* Rule number: 2556 ident_keywords_unambiguous.199 */
		0b000000000000000001000, /* Rule number: 2557 ident_keywords_unambiguous.200 */
		0b000000001000000000000, /* Rule number: 2558 ident_keywords_unambiguous.201 */
		0b000000000000100000000, /* Rule number: 2559 ident_keywords_unambiguous.202 */
		0b000000000000000010000, /* Rule number: 2560 ident_keywords_unambiguous.203 */
		0b000000000000000100000, /* Rule number: 2561 ident_keywords_unambiguous.204 */
		0b000000000000100000000, /* Rule number: 2562 ident_keywords_unambiguous.205 */
		0b001000000000000000000, /* Rule number: 2563 ident_keywords_unambiguous.206 */
		0b000000010000000000000, /* Rule number: 2564 ident_keywords_unambiguous.207 */
		0b000000000000000000001, /* Rule number: 2565 ident_keywords_unambiguous.208 */
		0b000000000100000000000, /* Rule number: 2566 ident_keywords_unambiguous.209 */
		0b000000000000001000000, /* Rule number: 2567 ident_keywords_unambiguous.210 */
		0b000000000001000000000, /* Rule number: 2568 ident_keywords_unambiguous.211 */
		0b000001000000000000000, /* Rule number: 2569 ident_keywords_unambiguous.212 */
		0b000000100000000000000, /* Rule number: 2570 ident_keywords_unambiguous.213 */
		0b000000000000000001000, /* Rule number: 2571 ident_keywords_unambiguous.214 */
		0b000000000100000000000, /* Rule number: 2572 ident_keywords_unambiguous.215 */
		0b000000000000010000000, /* Rule number: 2573 ident_keywords_unambiguous.216 */
		0b000000000000000100000, /* Rule number: 2574 ident_keywords_unambiguous.217 */
		0b000000001000000000000, /* Rule number: 2575 ident_keywords_unambiguous.218 */
		0b000000000000000100000, /* Rule number: 2576 ident_keywords_unambiguous.219 */
		0b000001000000000000000, /* Rule number: 2577 ident_keywords_unambiguous.220 */
		0b000010000000000000000, /* Rule number: 2578 ident_keywords_unambiguous.221 */
		0b000000000000001000000, /* Rule number: 2579 ident_keywords_unambiguous.222 */
		0b000001000000000000000, /* Rule number: 2580 ident_keywords_unambiguous.223 */
		0b000000000010000000000, /* Rule number: 2581 ident_keywords_unambiguous.224 */
		0b000000000000010000000, /* Rule number: 2582 ident_keywords_unambiguous.225 */
		0b010000000000000000000, /* Rule number: 2583 ident_keywords_unambiguous.226 */
		0b000000000001000000000, /* Rule number: 2584 ident_keywords_unambiguous.227 */
		0b010000000000000000000, /* Rule number: 2585 ident_keywords_unambiguous.228 */
		0b000000010000000000000, /* Rule number: 2586 ident_keywords_unambiguous.229 */
		0b000010000000000000000, /* Rule number: 2587 ident_keywords_unambiguous.230 */
		0b000010000000000000000, /* Rule number: 2588 ident_keywords_unambiguous.231 */
		0b000000000000000000001, /* Rule number: 2589 ident_keywords_unambiguous.232 */
		0b000000000000000001000, /* Rule number: 2590 ident_keywords_unambiguous.233 */
		0b010000000000000000000, /* Rule number: 2591 ident_keywords_unambiguous.234 */
		0b000000100000000000000, /* Rule number: 2592 ident_keywords_unambiguous.235 */
		0b000000000000000000100, /* Rule number: 2593 ident_keywords_unambiguous.236 */
		0b100000000000000000000, /* Rule number: 2594 ident_keywords_unambiguous.237 */
		0b000000000000000100000, /* Rule number: 2595 ident_keywords_unambiguous.238 */
		0b010000000000000000000, /* Rule number: 2596 ident_keywords_unambiguous.239 */
		0b001000000000000000000, /* Rule number: 2597 ident_keywords_unambiguous.240 */
		0b000000000000000100000, /* Rule number: 2598 ident_keywords_unambiguous.241 */
		0b000001000000000000000, /* Rule number: 2599 ident_keywords_unambiguous.242 */
		0b000000010000000000000, /* Rule number: 2600 ident_keywords_unambiguous.243 */
		0b000000000000000001000, /* Rule number: 2601 ident_keywords_unambiguous.244 */
		0b100000000000000000000, /* Rule number: 2602 ident_keywords_unambiguous.245 */
		0b000001000000000000000, /* Rule number: 2603 ident_keywords_unambiguous.246 */
		0b000000000010000000000, /* Rule number: 2604 ident_keywords_unambiguous.247 */
		0b000000000000000010000, /* Rule number: 2605 ident_keywords_unambiguous.248 */
		0b000100000000000000000, /* Rule number: 2606 ident_keywords_unambiguous.249 */
		0b000001000000000000000, /* Rule number: 2607 ident_keywords_unambiguous.250 */
		0b000000000000000000010, /* Rule number: 2608 ident_keywords_unambiguous.251 */
		0b100000000000000000000, /* Rule number: 2609 ident_keywords_unambiguous.252 */
		0b001000000000000000000, /* Rule number: 2610 ident_keywords_unambiguous.253 */
		0b000000000000000001000, /* Rule number: 2611 ident_keywords_unambiguous.254 */
		0b000010000000000000000, /* Rule number: 2612 ident_keywords_unambiguous.255 */
		0b010000000000000000000, /* Rule number: 2613 ident_keywords_unambiguous.256 */
		0b000000000010000000000, /* Rule number: 2614 ident_keywords_unambiguous.257 */
		0b000000000000000001000, /* Rule number: 2615 ident_keywords_unambiguous.258 */
		0b000000000010000000000, /* Rule number: 2616 ident_keywords_unambiguous.259 */
		0b000000010000000000000, /* Rule number: 2617 ident_keywords_unambiguous.260 */
		0b000000000000100000000, /* Rule number: 2618 ident_keywords_unambiguous.261 */
		0b000000000000000000010, /* Rule number: 2619 ident_keywords_unambiguous.262 */
		0b000000000010000000000, /* Rule number: 2620 ident_keywords_unambiguous.263 */
		0b000010000000000000000, /* Rule number: 2621 ident_keywords_unambiguous.264 */
		0b000000000000000001000, /* Rule number: 2622 ident_keywords_unambiguous.265 */
		0b000100000000000000000, /* Rule number: 2623 ident_keywords_unambiguous.266 */
		0b000000000000001000000, /* Rule number: 2624 ident_keywords_unambiguous.267 */
		0b000000001000000000000, /* Rule number: 2625 ident_keywords_unambiguous.268 */
		0b000001000000000000000, /* Rule number: 2626 ident_keywords_unambiguous.269 */
		0b000000000000000000100, /* Rule number: 2627 ident_keywords_unambiguous.270 */
		0b000000010000000000000, /* Rule number: 2628 ident_keywords_unambiguous.271 */
		0b000000000000000010000, /* Rule number: 2629 ident_keywords_unambiguous.272 */
		0b000000000100000000000, /* Rule number: 2630 ident_keywords_unambiguous.273 */
		0b000000000001000000000, /* Rule number: 2631 ident_keywords_unambiguous.274 */
		0b010000000000000000000, /* Rule number: 2632 ident_keywords_unambiguous.275 */
		0b000100000000000000000, /* Rule number: 2633 ident_keywords_unambiguous.276 */
		0b000000010000000000000, /* Rule number: 2634 ident_keywords_unambiguous.277 */
		0b000001000000000000000, /* Rule number: 2635 ident_keywords_unambiguous.278 */
		0b001000000000000000000, /* Rule number: 2636 ident_keywords_unambiguous.279 */
		0b000000000000000000100, /* Rule number: 2637 ident_keywords_unambiguous.280 */
		0b000000000000100000000, /* Rule number: 2638 ident_keywords_unambiguous.281 */
		0b001000000000000000000, /* Rule number: 2639 ident_keywords_unambiguous.282 */
		0b000000001000000000000, /* Rule number: 2640 ident_keywords_unambiguous.283 */
		0b010000000000000000000, /* Rule number: 2641 ident_keywords_unambiguous.284 */
		0b000000000000001000000, /* Rule number: 2642 ident_keywords_unambiguous.285 */
		0b000001000000000000000, /* Rule number: 2643 ident_keywords_unambiguous.286 */
		0b000000000000010000000, /* Rule number: 2644 ident_keywords_unambiguous.287 */
		0b000000000000000100000, /* Rule number: 2645 ident_keywords_unambiguous.288 */
		0b000001000000000000000, /* Rule number: 2646 ident_keywords_unambiguous.289 */
		0b000000000000010000000, /* Rule number: 2647 ident_keywords_unambiguous.290 */
		0b000000000000000000010, /* Rule number: 2648 ident_keywords_unambiguous.291 */
		0b000010000000000000000, /* Rule number: 2649 ident_keywords_unambiguous.292 */
		0b000100000000000000000, /* Rule number: 2650 ident_keywords_unambiguous.293 */
		0b000100000000000000000, /* Rule number: 2651 ident_keywords_unambiguous.294 */
		0b000000000000000000001, /* Rule number: 2652 ident_keywords_unambiguous.295 */
		0b000000000010000000000, /* Rule number: 2653 ident_keywords_unambiguous.296 */
		0b001000000000000000000, /* Rule number: 2654 ident_keywords_unambiguous.297 */
		0b000000000000001000000, /* Rule number: 2655 ident_keywords_unambiguous.298 */
		0b000000000000100000000, /* Rule number: 2656 ident_keywords_unambiguous.299 */
		0b000000000010000000000, /* Rule number: 2657 ident_keywords_unambiguous.300 */
		0b000010000000000000000, /* Rule number: 2658 ident_keywords_unambiguous.301 */
		0b000000000100000000000, /* Rule number: 2659 ident_keywords_unambiguous.302 */
		0b001000000000000000000, /* Rule number: 2660 ident_keywords_unambiguous.303 */
		0b000000000000000000001, /* Rule number: 2661 ident_keywords_unambiguous.304 */
		0b010000000000000000000, /* Rule number: 2662 ident_keywords_unambiguous.305 */
		0b000000000100000000000, /* Rule number: 2663 ident_keywords_unambiguous.306 */
		0b000000000000010000000, /* Rule number: 2664 ident_keywords_unambiguous.307 */
		0b000000100000000000000, /* Rule number: 2665 ident_keywords_unambiguous.308 */
		0b000000000000010000000, /* Rule number: 2666 ident_keywords_unambiguous.309 */
		0b000000000000010000000, /* Rule number: 2667 ident_keywords_unambiguous.310 */
		0b000000000000001000000, /* Rule number: 2668 ident_keywords_unambiguous.311 */
		0b000010000000000000000, /* Rule number: 2669 ident_keywords_unambiguous.312 */
		0b000000000100000000000, /* Rule number: 2670 ident_keywords_unambiguous.313 */
		0b000000000100000000000, /* Rule number: 2671 ident_keywords_unambiguous.314 */
		0b000000000100000000000, /* Rule number: 2672 ident_keywords_unambiguous.315 */
		0b000000000100000000000, /* Rule number: 2673 ident_keywords_unambiguous.316 */
		0b000001000000000000000, /* Rule number: 2674 ident_keywords_unambiguous.317 */
		0b001000000000000000000, /* Rule number: 2675 ident_keywords_unambiguous.318 */
		0b000000000000000000010, /* Rule number: 2676 ident_keywords_unambiguous.319 */
		0b000001000000000000000, /* Rule number: 2677 ident_keywords_unambiguous.320 */
		0b000000010000000000000, /* Rule number: 2678 ident_keywords_unambiguous.321 */
		0b000000000100000000000, /* Rule number: 2679 ident_keywords_unambiguous.322 */
		0b000000010000000000000, /* Rule number: 2680 ident_keywords_unambiguous.323 */
		0b000000100000000000000, /* Rule number: 2681 ident_keywords_unambiguous.324 */
		0b000000010000000000000, /* Rule number: 2682 ident_keywords_unambiguous.325 */
		0b000000000000100000000, /* Rule number: 2683 ident_keywords_unambiguous.326 */
		0b000100000000000000000, /* Rule number: 2684 ident_keywords_unambiguous.327 */
		0b000000000000010000000, /* Rule number: 2685 ident_keywords_unambiguous.328 */
		0b000100000000000000000, /* Rule number: 2686 ident_keywords_unambiguous.329 */
		0b000000000100000000000, /* Rule number: 2687 ident_keywords_unambiguous.330 */
		0b000100000000000000000, /* Rule number: 2688 ident_keywords_unambiguous.331 */
		0b000000000010000000000, /* Rule number: 2689 ident_keywords_unambiguous.332 */
		0b000010000000000000000, /* Rule number: 2690 ident_keywords_unambiguous.333 */
		0b000000000000010000000, /* Rule number: 2691 ident_keywords_unambiguous.334 */
		0b000100000000000000000, /* Rule number: 2692 ident_keywords_unambiguous.335 */
		0b000010000000000000000, /* Rule number: 2693 ident_keywords_unambiguous.336 */
		0b000000000000100000000, /* Rule number: 2694 ident_keywords_unambiguous.337 */
		0b000000000010000000000, /* Rule number: 2695 ident_keywords_unambiguous.338 */
		0b010000000000000000000, /* Rule number: 2696 ident_keywords_unambiguous.339 */
		0b000000000000000100000, /* Rule number: 2697 ident_keywords_unambiguous.340 */
		0b000000000000000000001, /* Rule number: 2698 ident_keywords_unambiguous.341 */
		0b000000000000000000001, /* Rule number: 2699 ident_keywords_unambiguous.342 */
		0b000010000000000000000, /* Rule number: 2700 ident_keywords_unambiguous.343 */
		0b000100000000000000000, /* Rule number: 2701 ident_keywords_unambiguous.344 */
		0b000000000010000000000, /* Rule number: 2702 ident_keywords_unambiguous.345 */
		0b000000000001000000000, /* Rule number: 2703 ident_keywords_unambiguous.346 */
		0b010000000000000000000, /* Rule number: 2704 ident_keywords_unambiguous.347 */
		0b000000000000000000100, /* Rule number: 2705 ident_keywords_unambiguous.348 */
		0b000000000001000000000, /* Rule number: 2706 ident_keywords_unambiguous.349 */
		0b000010000000000000000, /* Rule number: 2707 ident_keywords_unambiguous.350 */
		0b000000000000010000000, /* Rule number: 2708 ident_keywords_unambiguous.351 */
		0b000000000000001000000, /* Rule number: 2709 ident_keywords_unambiguous.352 */
		0b000000000001000000000, /* Rule number: 2710 ident_keywords_unambiguous.353 */
		0b000000000001000000000, /* Rule number: 2711 ident_keywords_unambiguous.354 */
		0b000100000000000000000, /* Rule number: 2712 ident_keywords_unambiguous.355 */
		0b001000000000000000000, /* Rule number: 2713 ident_keywords_unambiguous.356 */
		0b100000000000000000000, /* Rule number: 2714 ident_keywords_unambiguous.357 */
		0b000000000000000100000, /* Rule number: 2715 ident_keywords_unambiguous.358 */
		0b000000000010000000000, /* Rule number: 2716 ident_keywords_unambiguous.359 */
		0b000000000000000001000, /* Rule number: 2717 ident_keywords_unambiguous.360 */
		0b000000000000100000000, /* Rule number: 2718 ident_keywords_unambiguous.361 */
		0b100000000000000000000, /* Rule number: 2719 ident_keywords_unambiguous.362 */
		0b000000000000000100000, /* Rule number: 2720 ident_keywords_unambiguous.363 */
		0b000100000000000000000, /* Rule number: 2721 ident_keywords_unambiguous.364 */
		0b000000000000000010000, /* Rule number: 2722 ident_keywords_unambiguous.365 */
		0b000000000000000100000, /* Rule number: 2723 ident_keywords_unambiguous.366 */
		0b000000000010000000000, /* Rule number: 2724 ident_keywords_unambiguous.367 */
		0b000100000000000000000, /* Rule number: 2725 ident_keywords_unambiguous.368 */
		0b000000000000100000000, /* Rule number: 2726 ident_keywords_unambiguous.369 */
		0b000000001000000000000, /* Rule number: 2727 ident_keywords_unambiguous.370 */
		0b000000000000100000000, /* Rule number: 2728 ident_keywords_unambiguous.371 */
		0b000000000000010000000, /* Rule number: 2729 ident_keywords_unambiguous.372 */
		0b000000000000001000000, /* Rule number: 2730 ident_keywords_unambiguous.373 */
		0b000000000000000010000, /* Rule number: 2731 ident_keywords_unambiguous.374 */
		0b000000000000010000000, /* Rule number: 2732 ident_keywords_unambiguous.375 */
		0b100000000000000000000, /* Rule number: 2733 ident_keywords_unambiguous.376 */
		0b000000000000100000000, /* Rule number: 2734 ident_keywords_unambiguous.377 */
		0b000000000010000000000, /* Rule number: 2735 ident_keywords_unambiguous.378 */
		0b000000000000100000000, /* Rule number: 2736 ident_keywords_unambiguous.379 */
		0b000000000000010000000, /* Rule number: 2737 ident_keywords_unambiguous.380 */
		0b000000000000000010000, /* Rule number: 2738 ident_keywords_unambiguous.381 */
		0b000000000000000001000, /* Rule number: 2739 ident_keywords_unambiguous.382 */
		0b000000000000000100000, /* Rule number: 2740 ident_keywords_unambiguous.383 */
		0b000000010000000000000, /* Rule number: 2741 ident_keywords_unambiguous.384 */
		0b000000000000000000001, /* Rule number: 2742 ident_keywords_unambiguous.385 */
		0b000010000000000000000, /* Rule number: 2743 ident_keywords_unambiguous.386 */
		0b000000010000000000000, /* Rule number: 2744 ident_keywords_unambiguous.387 */
		0b000001000000000000000, /* Rule number: 2745 ident_keywords_unambiguous.388 */
		0b000000000000000000010, /* Rule number: 2746 ident_keywords_unambiguous.389 */
		0b000000000000000000010, /* Rule number: 2747 ident_keywords_unambiguous.390 */
		0b000000000001000000000, /* Rule number: 2748 ident_keywords_unambiguous.391 */
		0b000000001000000000000, /* Rule number: 2749 ident_keywords_unambiguous.392 */
		0b000000000000000000010, /* Rule number: 2750 ident_keywords_unambiguous.393 */
		0b000000000000001000000, /* Rule number: 2751 ident_keywords_unambiguous.394 */
		0b000000000000010000000, /* Rule number: 2752 ident_keywords_unambiguous.395 */
		0b000000000010000000000, /* Rule number: 2753 ident_keywords_unambiguous.396 */
		0b000000000000000000001, /* Rule number: 2754 ident_keywords_unambiguous.397 */
		0b000001000000000000000, /* Rule number: 2755 ident_keywords_unambiguous.398 */
		0b000000000000000100000, /* Rule number: 2756 ident_keywords_unambiguous.399 */
		0b000000000000000000100, /* Rule number: 2757 ident_keywords_unambiguous.400 */
		0b000000000000000001000, /* Rule number: 2758 ident_keywords_unambiguous.401 */
		0b000000000000000100000, /* Rule number: 2759 ident_keywords_unambiguous.402 */
		0b000000001000000000000, /* Rule number: 2760 ident_keywords_unambiguous.403 */
		0b001000000000000000000, /* Rule number: 2761 ident_keywords_unambiguous.404 */
		0b000001000000000000000, /* Rule number: 2762 ident_keywords_unambiguous.405 */
		0b000000001000000000000, /* Rule number: 2763 ident_keywords_unambiguous.406 */
		0b000000000000000100000, /* Rule number: 2764 ident_keywords_unambiguous.407 */
		0b000000000000010000000, /* Rule number: 2765 role_keyword.0 */
		0b000000100000000000000, /* Rule number: 2766 role_keyword.1 */
		0b000000010000000000000, /* Rule number: 2767 role_keyword.2 */
		0b000000000000001000000, /* Rule number: 2768 lvalue_keyword.0 */
		0b000000000000000010000, /* Rule number: 2769 lvalue_keyword.1 */
		0b000001000000000000000, /* Rule number: 2770 lvalue_keyword.2 */
		0b000000010000000000000, /* Rule number: 2771 lvalue_keyword.3 */
		0b000000000000000000100, /* Rule number: 2772 ident_keywords_ambiguous_4_system_variables.0 */
		0b000000000000100000000, /* Rule number: 2773 ident_keywords_ambiguous_4_system_variables.1 */
		0b000000010000000000000, /* Rule number: 2774 ident_keywords_ambiguous_4_system_variables.2 */
		0b000000000000001000000, /* Rule number: 2775 ident_keywords_ambiguous_4_system_variables.3 */
		0b000000000000000000100, /* Rule number: 2776 ident_keywords_ambiguous_4_system_variables.4 */
		0b000000000000000000010, /* Rule number: 2777 set.0 */
		0b010000000000000000000, /* Rule number: 2778 start_option_value_list.0 */
		0b000000010000000000000, /* Rule number: 2779 start_option_value_list.1 */
		0b001000000000000000000, /* Rule number: 2780 start_option_value_list.2 */
		0b000000010000000000000, /* Rule number: 2781 start_option_value_list.3 */
		0b000000000000000000100, /* Rule number: 2782 start_option_value_list.4 */
		0b010000000000000000000, /* Rule number: 2783 start_option_value_list.5 */
		0b001000000000000000000, /* Rule number: 2784 start_option_value_list.6 */
		0b000000100000000000000, /* Rule number: 2785 set_role_stmt.0 */
		0b000000000010000000000, /* Rule number: 2786 set_role_stmt.1 */
		0b000000000000000010000, /* Rule number: 2787 set_role_stmt.2 */
		0b000000000000000010000, /* Rule number: 2788 set_role_stmt.3 */
		0b000000000000000000010, /* Rule number: 2789 set_role_stmt.4 */
		0b000000100000000000000, /* Rule number: 2790 set_role_stmt.5 */
		0b000000000000001000000, /* Rule number: 2791 set_role_stmt.6 */
		0b000000000000000000100, /* Rule number: 2792 opt_except_role_list.0 */
		0b000000000000100000000, /* Rule number: 2793 opt_except_role_list.1 */
		0b000000001000000000000, /* Rule number: 2794 set_resource_group_stmt.0 */
		0b000000000001000000000, /* Rule number: 2795 set_resource_group_stmt.1 */
		0b000000010000000000000, /* Rule number: 2796 thread_id_list.0 */
		0b000000100000000000000, /* Rule number: 2797 thread_id_list.1 */
		0b010000000000000000000, /* Rule number: 2798 thread_id_list_options.0 */
		0b100000000000000000000, /* Rule number: 2799 start_option_value_list_following_option_type.0 */
		0b000000000000000000100, /* Rule number: 2800 start_option_value_list_following_option_type.1 */
		0b000000000000000001000, /* Rule number: 2801 option_value_list_continued.0 */
		0b000000000001000000000, /* Rule number: 2802 option_value_list_continued.1 */
		0b000000000010000000000, /* Rule number: 2803 option_value_list.0 */
		0b000000000100000000000, /* Rule number: 2804 option_value_list.1 */
		0b000100000000000000000, /* Rule number: 2805 option_value.0 */
		0b000000010000000000000, /* Rule number: 2806 option_value.1 */
		0b000000000010000000000, /* Rule number: 2807 option_type.0 */
		0b000000000000000000010, /* Rule number: 2808 option_type.1 */
		0b000000000000000100000, /* Rule number: 2809 option_type.2 */
		0b000000000000000100000, /* Rule number: 2810 option_type.3 */
		0b000000000100000000000, /* Rule number: 2811 option_type.4 */
		0b000010000000000000000, /* Rule number: 2812 opt_var_type.0 */
		0b000000000000000001000, /* Rule number: 2813 opt_var_type.1 */
		0b000000010000000000000, /* Rule number: 2814 opt_var_type.2 */
		0b010000000000000000000, /* Rule number: 2815 opt_var_type.3 */
		0b000000001000000000000, /* Rule number: 2816 opt_rvalue_system_variable_type.0 */
		0b000000000000000100000, /* Rule number: 2817 opt_rvalue_system_variable_type.1 */
		0b000000000000000000001, /* Rule number: 2818 opt_rvalue_system_variable_type.2 */
		0b000000000000000000001, /* Rule number: 2819 opt_rvalue_system_variable_type.3 */
		0b000000000010000000000, /* Rule number: 2820 opt_set_var_ident_type.0 */
		0b000000000000000000010, /* Rule number: 2821 opt_set_var_ident_type.1 */
		0b000010000000000000000, /* Rule number: 2822 opt_set_var_ident_type.2 */
		0b000000000000000100000, /* Rule number: 2823 opt_set_var_ident_type.3 */
		0b000001000000000000000, /* Rule number: 2824 opt_set_var_ident_type.4 */
		0b000000000000100000000, /* Rule number: 2825 opt_set_var_ident_type.5 */
		0b001000000000000000000, /* Rule number: 2826 option_value_following_option_type.0 */
		0b000000000000001000000, /* Rule number: 2827 option_value_no_option_type.0 */
		0b000000100000000000000, /* Rule number: 2828 option_value_no_option_type.1 */
		0b000000100000000000000, /* Rule number: 2829 option_value_no_option_type.2 */
		0b000001000000000000000, /* Rule number: 2830 option_value_no_option_type.3 */
		0b000000000001000000000, /* Rule number: 2831 option_value_no_option_type.4 */
		0b100000000000000000000, /* Rule number: 2832 option_value_no_option_type.5 */
		0b000000000001000000000, /* Rule number: 2833 option_value_no_option_type.6 */
		0b000010000000000000000, /* Rule number: 2834 lvalue_variable.0 */
		0b000000000001000000000, /* Rule number: 2835 lvalue_variable.1 */
		0b000000000000001000000, /* Rule number: 2836 lvalue_variable.2 */
		0b000000010000000000000, /* Rule number: 2837 rvalue_system_variable.0 */
		0b000000000000000001000, /* Rule number: 2838 rvalue_system_variable.1 */
		0b000000000000000010000, /* Rule number: 2839 transaction_characteristics.0 */
		0b000000000000000010000, /* Rule number: 2840 transaction_characteristics.1 */
		0b000000000000000000001, /* Rule number: 2841 transaction_access_mode.0 */
		0b000000100000000000000, /* Rule number: 2842 opt_transaction_access_mode.0 */
		0b000100000000000000000, /* Rule number: 2843 opt_transaction_access_mode.1 */
		0b000000000000000000001, /* Rule number: 2844 isolation_level.0 */
		0b001000000000000000000, /* Rule number: 2845 opt_isolation_level.0 */
		0b000010000000000000000, /* Rule number: 2846 opt_isolation_level.1 */
		0b000000000000000100000, /* Rule number: 2847 transaction_access_mode_types.0 */
		0b000000000000000000001, /* Rule number: 2848 transaction_access_mode_types.1 */
		0b000000000000100000000, /* Rule number: 2849 isolation_types.0 */
		0b000000000000000000010, /* Rule number: 2850 isolation_types.1 */
		0b000100000000000000000, /* Rule number: 2851 isolation_types.2 */
		0b000000000010000000000, /* Rule number: 2852 isolation_types.3 */
		0b000000000000000010000, /* Rule number: 2853 set_expr_or_default.0 */
		0b000000000100000000000, /* Rule number: 2854 set_expr_or_default.1 */
		0b001000000000000000000, /* Rule number: 2855 set_expr_or_default.2 */
		0b000100000000000000000, /* Rule number: 2856 set_expr_or_default.3 */
		0b000000000000000100000, /* Rule number: 2857 set_expr_or_default.4 */
		0b100000000000000000000, /* Rule number: 2858 set_expr_or_default.5 */
		0b000000000100000000000, /* Rule number: 2859 set_expr_or_default.6 */
		0b000000000000000000100, /* Rule number: 2860 $@53 */
		0b000000100000000000000, /* Rule number: 2861 lock.0 */
		0b000000001000000000000, /* Rule number: 2862 lock.1 */
		0b000000000000000000100, /* Rule number: 2863 table_or_tables.0 */
		0b000100000000000000000, /* Rule number: 2864 table_or_tables.1 */
		0b010000000000000000000, /* Rule number: 2865 table_lock_list.0 */
		0b000000010000000000000, /* Rule number: 2866 table_lock_list.1 */
		0b000000000001000000000, /* Rule number: 2867 table_lock.0 */
		0b000000000000100000000, /* Rule number: 2868 lock_option.0 */
		0b000010000000000000000, /* Rule number: 2869 lock_option.1 */
		0b000000000000100000000, /* Rule number: 2870 lock_option.2 */
		0b001000000000000000000, /* Rule number: 2871 $@54 */
		0b000000000001000000000, /* Rule number: 2872 unlock.0 */
		0b000000000100000000000, /* Rule number: 2873 unlock.1 */
		0b000100000000000000000, /* Rule number: 2874 shutdown_stmt.0 */
		0b000000000010000000000, /* Rule number: 2875 restart_server_stmt.0 */
		0b000000000000010000000, /* Rule number: 2876 alter_instance_stmt.0 */
		0b000000000000100000000, /* Rule number: 2877 alter_instance_action.0 */
		0b000001000000000000000, /* Rule number: 2878 alter_instance_action.1 */
		0b000000000000000001000, /* Rule number: 2879 alter_instance_action.2 */
		0b000000000001000000000, /* Rule number: 2880 alter_instance_action.3 */
		0b000000000000000001000, /* Rule number: 2881 alter_instance_action.4 */
		0b000000100000000000000, /* Rule number: 2882 alter_instance_action.5 */
		0b000000000000100000000, /* Rule number: 2883 alter_instance_action.6 */
		0b010000000000000000000, /* Rule number: 2884 alter_instance_action.7 */
		0b000000010000000000000, /* Rule number: 2885 handler_stmt.0 */
		0b000001000000000000000, /* Rule number: 2886 handler_stmt.1 */
		0b000000010000000000000, /* Rule number: 2887 handler_stmt.2 */
		0b000000010000000000000, /* Rule number: 2888 handler_stmt.3 */
		0b000000010000000000000, /* Rule number: 2889 handler_stmt.4 */
		0b000000000000000001000, /* Rule number: 2890 handler_scan_function.0 */
		0b000010000000000000000, /* Rule number: 2891 handler_scan_function.1 */
		0b000000000000000000010, /* Rule number: 2892 handler_rkey_function.0 */
		0b000000000001000000000, /* Rule number: 2893 handler_rkey_function.1 */
		0b000000010000000000000, /* Rule number: 2894 handler_rkey_function.2 */
		0b000001000000000000000, /* Rule number: 2895 handler_rkey_function.3 */
		0b000000000000100000000, /* Rule number: 2896 handler_rkey_mode.0 */
		0b000000000010000000000, /* Rule number: 2897 handler_rkey_mode.1 */
		0b000000000010000000000, /* Rule number: 2898 handler_rkey_mode.2 */
		0b000000000000010000000, /* Rule number: 2899 handler_rkey_mode.3 */
		0b000000000000000010000, /* Rule number: 2900 handler_rkey_mode.4 */
		0b000000000000000100000, /* Rule number: 2901 $@55 */
		0b000000000000010000000, /* Rule number: 2902 revoke.0 */
		0b000001000000000000000, /* Rule number: 2903 revoke.1 */
		0b000000000000000000001, /* Rule number: 2904 revoke.2 */
		0b100000000000000000000, /* Rule number: 2905 revoke.3 */
		0b000100000000000000000, /* Rule number: 2906 revoke.4 */
		0b000000100000000000000, /* Rule number: 2907 $@56 */
		0b010000000000000000000, /* Rule number: 2908 grant.0 */
		0b000000000000000001000, /* Rule number: 2909 grant.1 */
		0b000000000000010000000, /* Rule number: 2910 grant.2 */
		0b000000000001000000000, /* Rule number: 2911 grant.3 */
		0b000000000000000000100, /* Rule number: 2912 opt_acl_type.0 */
		0b000001000000000000000, /* Rule number: 2913 opt_acl_type.1 */
		0b000000100000000000000, /* Rule number: 2914 opt_acl_type.2 */
		0b000000001000000000000, /* Rule number: 2915 opt_acl_type.3 */
		0b000000000001000000000, /* Rule number: 2916 opt_privileges.0 */
		0b000000000000001000000, /* Rule number: 2917 opt_privileges.1 */
		0b000010000000000000000, /* Rule number: 2918 role_or_privilege_list.0 */
		0b100000000000000000000, /* Rule number: 2919 role_or_privilege_list.1 */
		0b000000000001000000000, /* Rule number: 2920 role_or_privilege.0 */
		0b000000000100000000000, /* Rule number: 2921 role_or_privilege.1 */
		0b000000001000000000000, /* Rule number: 2922 role_or_privilege.2 */
		0b000000000010000000000, /* Rule number: 2923 role_or_privilege.3 */
		0b000000000000010000000, /* Rule number: 2924 role_or_privilege.4 */
		0b000000000000000010000, /* Rule number: 2925 role_or_privilege.5 */
		0b000000000000000000100, /* Rule number: 2926 role_or_privilege.6 */
		0b000000000000010000000, /* Rule number: 2927 role_or_privilege.7 */
		0b000001000000000000000, /* Rule number: 2928 role_or_privilege.8 */
		0b000000000000000000001, /* Rule number: 2929 role_or_privilege.9 */
		0b000000000000000000100, /* Rule number: 2930 role_or_privilege.10 */
		0b000000000001000000000, /* Rule number: 2931 role_or_privilege.11 */
		0b000000000100000000000, /* Rule number: 2932 role_or_privilege.12 */
		0b000000000000000000010, /* Rule number: 2933 role_or_privilege.13 */
		0b000000000010000000000, /* Rule number: 2934 role_or_privilege.14 */
		0b000000000000010000000, /* Rule number: 2935 role_or_privilege.15 */
		0b000100000000000000000, /* Rule number: 2936 role_or_privilege.16 */
		0b000000000010000000000, /* Rule number: 2937 role_or_privilege.17 */
		0b000000010000000000000, /* Rule number: 2938 role_or_privilege.18 */
		0b100000000000000000000, /* Rule number: 2939 role_or_privilege.19 */
		0b000000000100000000000, /* Rule number: 2940 role_or_privilege.20 */
		0b000000000000000000001, /* Rule number: 2941 role_or_privilege.21 */
		0b000000000000000010000, /* Rule number: 2942 role_or_privilege.22 */
		0b000100000000000000000, /* Rule number: 2943 role_or_privilege.23 */
		0b000000000001000000000, /* Rule number: 2944 role_or_privilege.24 */
		0b000000000000000000100, /* Rule number: 2945 role_or_privilege.25 */
		0b000000000000010000000, /* Rule number: 2946 role_or_privilege.26 */
		0b100000000000000000000, /* Rule number: 2947 role_or_privilege.27 */
		0b000000000000000100000, /* Rule number: 2948 role_or_privilege.28 */
		0b000000000001000000000, /* Rule number: 2949 role_or_privilege.29 */
		0b001000000000000000000, /* Rule number: 2950 role_or_privilege.30 */
		0b000000000000001000000, /* Rule number: 2951 role_or_privilege.31 */
		0b000000000000000001000, /* Rule number: 2952 role_or_privilege.32 */
		0b000000000000000000001, /* Rule number: 2953 role_or_privilege.33 */
		0b000000000001000000000, /* Rule number: 2954 opt_with_admin_option.0 */
		0b000100000000000000000, /* Rule number: 2955 opt_with_admin_option.1 */
		0b000000000010000000000, /* Rule number: 2956 opt_and.0 */
		0b000000000000000001000, /* Rule number: 2957 opt_and.1 */
		0b001000000000000000000, /* Rule number: 2958 require_list.0 */
		0b000000000000000000010, /* Rule number: 2959 require_list.1 */
		0b000001000000000000000, /* Rule number: 2960 require_list_element.0 */
		0b000000000000001000000, /* Rule number: 2961 require_list_element.1 */
		0b000000000001000000000, /* Rule number: 2962 require_list_element.2 */
		0b000000100000000000000, /* Rule number: 2963 grant_ident.0 */
		0b000001000000000000000, /* Rule number: 2964 grant_ident.1 */
		0b000000000000000000010, /* Rule number: 2965 grant_ident.2 */
		0b000000000000100000000, /* Rule number: 2966 grant_ident.3 */
		0b000000010000000000000, /* Rule number: 2967 grant_ident.4 */
		0b000000010000000000000, /* Rule number: 2968 user_list.0 */
		0b000000100000000000000, /* Rule number: 2969 user_list.1 */
		0b000000000000000100000, /* Rule number: 2970 role_list.0 */
		0b000000000000000010000, /* Rule number: 2971 role_list.1 */
		0b000000000010000000000, /* Rule number: 2972 opt_retain_current_password.0 */
		0b001000000000000000000, /* Rule number: 2973 opt_retain_current_password.1 */
		0b000000001000000000000, /* Rule number: 2974 opt_discard_old_password.0 */
		0b000000000000000000010, /* Rule number: 2975 opt_discard_old_password.1 */
		0b000000000000000001000, /* Rule number: 2976 opt_user_registration.0 */
		0b000000000000100000000, /* Rule number: 2977 opt_user_registration.1 */
		0b000000000001000000000, /* Rule number: 2978 opt_user_registration.2 */
		0b000010000000000000000, /* Rule number: 2979 create_user.0 */
		0b000000000000100000000, /* Rule number: 2980 create_user.1 */
		0b000000000000000000100, /* Rule number: 2981 create_user.2 */
		0b000000000000000000010, /* Rule number: 2982 opt_create_user_with_mfa.0 */
		0b000000000000001000000, /* Rule number: 2983 opt_create_user_with_mfa.1 */
		0b010000000000000000000, /* Rule number: 2984 opt_create_user_with_mfa.2 */
		0b000000000000001000000, /* Rule number: 2985 identification.0 */
		0b000000000001000000000, /* Rule number: 2986 identification.1 */
		0b000000000000000010000, /* Rule number: 2987 identification.2 */
		0b000000000000000100000, /* Rule number: 2988 identification.3 */
		0b000000000010000000000, /* Rule number: 2989 identification.4 */
		0b000000000001000000000, /* Rule number: 2990 identification.5 */
		0b000000000000000010000, /* Rule number: 2991 identified_by_password.0 */
		0b000000000000000010000, /* Rule number: 2992 identified_by_random_password.0 */
		0b000000000000000000100, /* Rule number: 2993 identified_with_plugin.0 */
		0b000000000000000001000, /* Rule number: 2994 identified_with_plugin_as_auth.0 */
		0b000100000000000000000, /* Rule number: 2995 identified_with_plugin_by_password.0 */
		0b100000000000000000000, /* Rule number: 2996 identified_with_plugin_by_random_password.0 */
		0b001000000000000000000, /* Rule number: 2997 opt_initial_auth.0 */
		0b001000000000000000000, /* Rule number: 2998 opt_initial_auth.1 */
		0b000000000000000000100, /* Rule number: 2999 opt_initial_auth.2 */
		0b000000000000010000000, /* Rule number: 3000 alter_user.0 */
		0b000000100000000000000, /* Rule number: 3001 alter_user.1 */
		0b000000000000001000000, /* Rule number: 3002 alter_user.2 */
		0b000000000000000000010, /* Rule number: 3003 alter_user.3 */
		0b100000000000000000000, /* Rule number: 3004 alter_user.4 */
		0b000000000000000010000, /* Rule number: 3005 alter_user.5 */
		0b000000000000000010000, /* Rule number: 3006 alter_user.6 */
		0b000000000000010000000, /* Rule number: 3007 alter_user.7 */
		0b000100000000000000000, /* Rule number: 3008 alter_user.8 */
		0b000000100000000000000, /* Rule number: 3009 alter_user.9 */
		0b000000000000000000001, /* Rule number: 3010 alter_user.10 */
		0b000000001000000000000, /* Rule number: 3011 alter_user.11 */
		0b000000000000000000010, /* Rule number: 3012 alter_user.12 */
		0b000000100000000000000, /* Rule number: 3013 alter_user.13 */
		0b000000000000000100000, /* Rule number: 3014 alter_user.14 */
		0b000000000010000000000, /* Rule number: 3015 alter_user.15 */
		0b000000000100000000000, /* Rule number: 3016 factor.0 */
		0b000000000000000100000, /* Rule number: 3017 create_user_list.0 */
		0b000000000000010000000, /* Rule number: 3018 create_user_list.1 */
		0b010000000000000000000, /* Rule number: 3019 alter_user_list.0 */
		0b000000000100000000000, /* Rule number: 3020 alter_user_list.1 */
		0b000000000000000000100, /* Rule number: 3021 opt_column_list.0 */
		0b000000000000000000001, /* Rule number: 3022 opt_column_list.1 */
		0b000000000000000000001, /* Rule number: 3023 column_list.0 */
		0b000100000000000000000, /* Rule number: 3024 column_list.1 */
		0b000000000010000000000, /* Rule number: 3025 require_clause.0 */
		0b000000000000000001000, /* Rule number: 3026 require_clause.1 */
		0b000000000000000010000, /* Rule number: 3027 require_clause.2 */
		0b000000000001000000000, /* Rule number: 3028 require_clause.3 */
		0b000001000000000000000, /* Rule number: 3029 require_clause.4 */
		0b000000000010000000000, /* Rule number: 3030 grant_options.0 */
		0b100000000000000000000, /* Rule number: 3031 grant_options.1 */
		0b000000000000000100000, /* Rule number: 3032 opt_grant_option.0 */
		0b000000000000000000010, /* Rule number: 3033 opt_grant_option.1 */
		0b100000000000000000000, /* Rule number: 3034 opt_with_roles.0 */
		0b000000010000000000000, /* Rule number: 3035 opt_with_roles.1 */
		0b000000000010000000000, /* Rule number: 3036 opt_with_roles.2 */
		0b000000000100000000000, /* Rule number: 3037 opt_with_roles.3 */
		0b001000000000000000000, /* Rule number: 3038 opt_with_roles.4 */
		0b000001000000000000000, /* Rule number: 3039 opt_grant_as.0 */
		0b000000000000000010000, /* Rule number: 3040 opt_grant_as.1 */
		0b000000000001000000000, /* Rule number: 3041 $@57 */
		0b000000000000000010000, /* Rule number: 3042 begin_stmt.0 */
		0b000000000000001000000, /* Rule number: 3043 opt_work.0 */
		0b000000000000000100000, /* Rule number: 3044 opt_work.1 */
		0b000000000010000000000, /* Rule number: 3045 opt_chain.0 */
		0b000000000010000000000, /* Rule number: 3046 opt_chain.1 */
		0b000000000001000000000, /* Rule number: 3047 opt_chain.2 */
		0b000000000000010000000, /* Rule number: 3048 opt_release.0 */
		0b000000000000000100000, /* Rule number: 3049 opt_release.1 */
		0b000000000000000000001, /* Rule number: 3050 opt_release.2 */
		0b000000000000000000001, /* Rule number: 3051 opt_savepoint.0 */
		0b000001000000000000000, /* Rule number: 3052 opt_savepoint.1 */
		0b000000000000000001000, /* Rule number: 3053 commit.0 */
		0b000000100000000000000, /* Rule number: 3054 rollback.0 */
		0b000000000000000001000, /* Rule number: 3055 rollback.1 */
		0b000000000000100000000, /* Rule number: 3056 savepoint.0 */
		0b000000000000000010000, /* Rule number: 3057 release.0 */
		0b000001000000000000000, /* Rule number: 3058 union_option.0 */
		0b000000010000000000000, /* Rule number: 3059 union_option.1 */
		0b000000000000000000100, /* Rule number: 3060 union_option.2 */
		0b000000010000000000000, /* Rule number: 3061 row_subquery.0 */
		0b010000000000000000000, /* Rule number: 3062 table_subquery.0 */
		0b000000000000000000001, /* Rule number: 3063 subquery.0 */
		0b000000000000000010000, /* Rule number: 3064 query_spec_option.0 */
		0b000000000000000100000, /* Rule number: 3065 query_spec_option.1 */
		0b000000000000000000100, /* Rule number: 3066 query_spec_option.2 */
		0b100000000000000000000, /* Rule number: 3067 query_spec_option.3 */
		0b000000000000000000010, /* Rule number: 3068 query_spec_option.4 */
		0b000000000100000000000, /* Rule number: 3069 query_spec_option.5 */
		0b100000000000000000000, /* Rule number: 3070 query_spec_option.6 */
		0b000000000000010000000, /* Rule number: 3071 query_spec_option.7 */
		0b100000000000000000000, /* Rule number: 3072 init_lex_create_info.0 */
		0b000100000000000000000, /* Rule number: 3073 view_or_trigger_or_sp_or_event.0 */
		0b000100000000000000000, /* Rule number: 3074 view_or_trigger_or_sp_or_event.1 */
		0b000000000010000000000, /* Rule number: 3075 view_or_trigger_or_sp_or_event.2 */
		0b000000000000000001000, /* Rule number: 3076 definer_tail.0 */
		0b000000000000100000000, /* Rule number: 3077 definer_tail.1 */
		0b000000001000000000000, /* Rule number: 3078 definer_tail.2 */
		0b010000000000000000000, /* Rule number: 3079 definer_tail.3 */
		0b000000000000000100000, /* Rule number: 3080 definer_tail.4 */
		0b000000000000100000000, /* Rule number: 3081 no_definer_tail.0 */
		0b000001000000000000000, /* Rule number: 3082 no_definer_tail.1 */
		0b000100000000000000000, /* Rule number: 3083 no_definer_tail.2 */
		0b000000000000010000000, /* Rule number: 3084 no_definer_tail.3 */
		0b000000000000010000000, /* Rule number: 3085 no_definer_tail.4 */
		0b000000000100000000000, /* Rule number: 3086 no_definer_tail.5 */
		0b000000000100000000000, /* Rule number: 3087 definer_opt.0 */
		0b000100000000000000000, /* Rule number: 3088 definer_opt.1 */
		0b010000000000000000000, /* Rule number: 3089 no_definer.0 */
		0b000100000000000000000, /* Rule number: 3090 definer.0 */
		0b000000000001000000000, /* Rule number: 3091 view_replace_or_algorithm.0 */
		0b000000000010000000000, /* Rule number: 3092 view_replace_or_algorithm.1 */
		0b000010000000000000000, /* Rule number: 3093 view_replace_or_algorithm.2 */
		0b000000000000000000100, /* Rule number: 3094 view_replace.0 */
		0b000000000001000000000, /* Rule number: 3095 view_algorithm.0 */
		0b000000000000000000100, /* Rule number: 3096 view_algorithm.1 */
		0b000100000000000000000, /* Rule number: 3097 view_algorithm.2 */
		0b000000000000000010000, /* Rule number: 3098 view_suid.0 */
		0b000000000000000000100, /* Rule number: 3099 view_suid.1 */
		0b000100000000000000000, /* Rule number: 3100 view_suid.2 */
		0b000000000000000000001, /* Rule number: 3101 $@58 */
		0b000000000100000000000, /* Rule number: 3102 view_tail.0 */
		0b000001000000000000000, /* Rule number: 3103 view_query_block.0 */
		0b000000000000000001000, /* Rule number: 3104 view_check_option.0 */
		0b000000010000000000000, /* Rule number: 3105 view_check_option.1 */
		0b000000000000001000000, /* Rule number: 3106 view_check_option.2 */
		0b000000000000000010000, /* Rule number: 3107 view_check_option.3 */
		0b000000010000000000000, /* Rule number: 3108 trigger_action_order.0 */
		0b000000000010000000000, /* Rule number: 3109 trigger_action_order.1 */
		0b000000010000000000000, /* Rule number: 3110 trigger_follows_precedes_clause.0 */
		0b000000000000000001000, /* Rule number: 3111 trigger_follows_precedes_clause.1 */
		0b000000000000100000000, /* Rule number: 3112 $@59 */
		0b000000000000000100000, /* Rule number: 3113 trigger_tail.0 */
		0b000010000000000000000, /* Rule number: 3114 udf_tail.0 */
		0b000000000010000000000, /* Rule number: 3115 udf_tail.1 */
		0b000001000000000000000, /* Rule number: 3116 $@60 */
		0b000000000000000100000, /* Rule number: 3117 $@61 */
		0b000000000010000000000, /* Rule number: 3118 $@62 */
		0b010000000000000000000, /* Rule number: 3119 $@63 */
		0b000000001000000000000, /* Rule number: 3120 sf_tail.0 */
		0b000100000000000000000, /* Rule number: 3121 routine_string.0 */
		0b000000000000100000000, /* Rule number: 3122 routine_string.1 */
		0b000000000000000100000, /* Rule number: 3123 stored_routine_body.0 */
		0b000000000000000001000, /* Rule number: 3124 stored_routine_body.1 */
		0b000000001000000000000, /* Rule number: 3125 $@64 */
		0b000000000000000000001, /* Rule number: 3126 $@65 */
		0b000000000000001000000, /* Rule number: 3127 $@66 */
		0b000000000000000000001, /* Rule number: 3128 $@67 */
		0b000000001000000000000, /* Rule number: 3129 sp_tail.0 */
		0b000000000000000001000, /* Rule number: 3130 xa.0 */
		0b000010000000000000000, /* Rule number: 3131 xa.1 */
		0b000000100000000000000, /* Rule number: 3132 xa.2 */
		0b000000000000000001000, /* Rule number: 3133 xa.3 */
		0b000000000010000000000, /* Rule number: 3134 xa.4 */
		0b000100000000000000000, /* Rule number: 3135 xa.5 */
		0b000000000001000000000, /* Rule number: 3136 opt_convert_xid.0 */
		0b000000000000000010000, /* Rule number: 3137 opt_convert_xid.1 */
		0b000000000000000000010, /* Rule number: 3138 xid.0 */
		0b000000000000010000000, /* Rule number: 3139 xid.1 */
		0b100000000000000000000, /* Rule number: 3140 xid.2 */
		0b000100000000000000000, /* Rule number: 3141 begin_or_start.0 */
		0b000000000000000001000, /* Rule number: 3142 begin_or_start.1 */
		0b000001000000000000000, /* Rule number: 3143 opt_join_or_resume.0 */
		0b000000000001000000000, /* Rule number: 3144 opt_join_or_resume.1 */
		0b000000100000000000000, /* Rule number: 3145 opt_join_or_resume.2 */
		0b000100000000000000000, /* Rule number: 3146 opt_one_phase.0 */
		0b000000000000001000000, /* Rule number: 3147 opt_one_phase.1 */
		0b000010000000000000000, /* Rule number: 3148 opt_suspend.0 */
		0b000000000000000000010, /* Rule number: 3149 opt_suspend.1 */
		0b001000000000000000000, /* Rule number: 3150 opt_suspend.2 */
		0b000000000001000000000, /* Rule number: 3151 install_option_type.0 */
		0b000000000010000000000, /* Rule number: 3152 install_option_type.1 */
		0b000000000000000000001, /* Rule number: 3153 install_option_type.2 */
		0b000000000000010000000, /* Rule number: 3154 install_set_rvalue.0 */
		0b000000000000000000100, /* Rule number: 3155 install_set_rvalue.1 */
		0b000000000001000000000, /* Rule number: 3156 install_set_value.0 */
		0b000000000000000000001, /* Rule number: 3157 install_set_value_list.0 */
		0b010000000000000000000, /* Rule number: 3158 install_set_value_list.1 */
		0b000000000000010000000, /* Rule number: 3159 opt_install_set_value_list.0 */
		0b000000000000000000010, /* Rule number: 3160 opt_install_set_value_list.1 */
		0b000000000010000000000, /* Rule number: 3161 install_stmt.0 */
		0b000000000000001000000, /* Rule number: 3162 install_stmt.1 */
		0b100000000000000000000, /* Rule number: 3163 uninstall.0 */
		0b000000000000010000000, /* Rule number: 3164 uninstall.1 */
		0b000000000100000000000, /* Rule number: 3165 TEXT_STRING_sys_list.0 */
		0b100000000000000000000, /* Rule number: 3166 TEXT_STRING_sys_list.1 */
		0b000000000000100000000, /* Rule number: 3167 import_stmt.0 */
		0b100000000000000000000, /* Rule number: 3168 clone_stmt.0 */
		0b000000000010000000000, /* Rule number: 3169 clone_stmt.1 */
		0b000100000000000000000, /* Rule number: 3170 opt_datadir_ssl.0 */
		0b000000000000010000000, /* Rule number: 3171 opt_datadir_ssl.1 */
		0b000000000100000000000, /* Rule number: 3172 opt_ssl.0 */
		0b000100000000000000000, /* Rule number: 3173 opt_ssl.1 */
		0b000000010000000000000, /* Rule number: 3174 opt_ssl.2 */
		0b000000001000000000000, /* Rule number: 3175 resource_group_types.0 */
		0b000000000000000000001, /* Rule number: 3176 resource_group_types.1 */
		0b001000000000000000000, /* Rule number: 3177 opt_resource_group_vcpu_list.0 */
		0b000000000000000000010, /* Rule number: 3178 opt_resource_group_vcpu_list.1 */
		0b000000000000000000001, /* Rule number: 3179 vcpu_range_spec_list.0 */
		0b000000000000000010000, /* Rule number: 3180 vcpu_range_spec_list.1 */
		0b000010000000000000000, /* Rule number: 3181 vcpu_num_or_range.0 */
		0b000001000000000000000, /* Rule number: 3182 vcpu_num_or_range.1 */
		0b000000000000000000100, /* Rule number: 3183 signed_num.0 */
		0b000001000000000000000, /* Rule number: 3184 signed_num.1 */
		0b000000010000000000000, /* Rule number: 3185 opt_resource_group_priority.0 */
		0b000000000000010000000, /* Rule number: 3186 opt_resource_group_priority.1 */
		0b000000000000000000001, /* Rule number: 3187 opt_resource_group_enable_disable.0 */
		0b000000000000100000000, /* Rule number: 3188 opt_resource_group_enable_disable.1 */
		0b000000000000000000010, /* Rule number: 3189 opt_resource_group_enable_disable.2 */
		0b000000000000010000000, /* Rule number: 3190 opt_force.0 */
		0b000000000001000000000, /* Rule number: 3191 opt_force.1 */
		0b000000000001000000000, /* Rule number: 3192 json_attribute.0 */
	};
}

%%

start_entry:
sql_statement 
|GRAMMAR_SELECTOR_EXPR bit_expr END_OF_INPUT {
            ITEMIZE($2, &$2);
            static_cast<Expression_parser_state *>(YYP)->result= $2;
          }
|GRAMMAR_SELECTOR_PART partition_clause END_OF_INPUT {
            
            CONTEXTUALIZE($2);
            static_cast<Partition_expr_parser_state *>(YYP)->result=
              &$2->part_info;
          }
|GRAMMAR_SELECTOR_GCOL IDENT_sys '(' expr ')' END_OF_INPUT {
            

            
            if (!is_identifier($2, "PARSE_GCOL_EXPR"))
              MYSQL_YYABORT;

            auto gcol_info= NEW_PTN Value_generator;
            if (gcol_info == nullptr)
              MYSQL_YYABORT; 
            ITEMIZE($4, &$4);
            gcol_info->expr_item= $4;
            static_cast<Gcol_expr_parser_state *>(YYP)->result= gcol_info;
          }
|GRAMMAR_SELECTOR_CTE table_subquery END_OF_INPUT {
            static_cast<Common_table_expr_parser_state *>(YYP)->result= $2;
          }
|GRAMMAR_SELECTOR_DERIVED_EXPR expr END_OF_INPUT {
           ITEMIZE($2, &$2);
           static_cast<Derived_expr_parser_state *>(YYP)->result= $2;
         }
;

sql_statement:
END_OF_INPUT {
            THD *thd= YYTHD;
            if (!thd->is_bootstrap_system_thread() &&
                !thd->m_parser_state->has_comment())
            {
              my_error(ER_EMPTY_QUERY, MYF(0));
              MYSQL_YYABORT;
            }
            thd->lex->sql_command= SQLCOM_EMPTY_QUERY;
            YYLIP->found_semicolon= nullptr;
          }
|simple_statement_or_begin {
            Lex_input_stream *lip = YYLIP;

            if (YYTHD->get_protocol()->has_client_capability(CLIENT_MULTI_QUERIES) &&
                lip->multi_statements &&
                ! lip->eof())
            {
              
              lip->next_state= MY_LEX_END;
              lip->found_semicolon= lip->get_ptr();
            }
            else
            {
              
              lip->found_semicolon= nullptr;
            }
          }';' opt_end_of_input 
|simple_statement_or_begin END_OF_INPUT {
            
            YYLIP->found_semicolon= nullptr;
          }
;

opt_end_of_input:
%empty 
|END_OF_INPUT 
;

simple_statement_or_begin:
simple_statement { *parse_tree= $1; }
|begin_stmt 
;

simple_statement:
alter_database_stmt { $$= nullptr; }
|alter_event_stmt { $$= nullptr; }
|alter_function_stmt { $$= nullptr; }
|alter_instance_stmt 
|alter_logfile_stmt { $$= nullptr; }
|alter_procedure_stmt { $$= nullptr; }
|alter_resource_group_stmt 
|alter_server_stmt { $$= nullptr; }
|alter_tablespace_stmt { $$= nullptr; }
|alter_undo_tablespace_stmt { $$= nullptr; }
|alter_table_stmt 
|alter_user_stmt { $$= nullptr; }
|alter_view_stmt { $$= nullptr; }
|analyze_table_stmt 
|binlog_base64_event { $$= nullptr; }
|call_stmt 
|change_replication_stmt { $$= nullptr; }
|check_table_stmt 
|checksum { $$= nullptr; }
|clone_stmt { $$= nullptr; }
|commit { $$= nullptr; }
|create { $$= nullptr; }
|create_index_stmt 
|create_resource_group_stmt 
|create_role_stmt 
|create_srs_stmt 
|create_table_stmt 
|deallocate { $$= nullptr; }
|delete_stmt 
|describe_stmt 
|do_stmt 
|drop_database_stmt { $$= nullptr; }
|drop_event_stmt { $$= nullptr; }
|drop_function_stmt { $$= nullptr; }
|drop_index_stmt 
|drop_logfile_stmt { $$= nullptr; }
|drop_procedure_stmt { $$= nullptr; }
|drop_resource_group_stmt 
|drop_role_stmt 
|drop_server_stmt { $$= nullptr; }
|drop_srs_stmt 
|drop_tablespace_stmt { $$= nullptr; }
|drop_undo_tablespace_stmt { $$= nullptr; }
|drop_table_stmt { $$= nullptr; }
|drop_trigger_stmt { $$= nullptr; }
|drop_user_stmt { $$= nullptr; }
|drop_view_stmt { $$= nullptr; }
|execute { $$= nullptr; }
|explain_stmt 
|flush { $$= nullptr; }
|get_diagnostics { $$= nullptr; }
|group_replication { $$= nullptr; }
|grant { $$= nullptr; }
|handler_stmt 
|help { $$= nullptr; }
|import_stmt { $$= nullptr; }
|insert_stmt 
|install_stmt 
|kill { $$= nullptr; }
|load_stmt 
|lock { $$= nullptr; }
|optimize_table_stmt 
|keycache_stmt 
|preload_stmt 
|prepare { $$= nullptr; }
|purge { $$= nullptr; }
|release { $$= nullptr; }
|rename { $$= nullptr; }
|repair_table_stmt 
|replace_stmt 
|reset { $$= nullptr; }
|resignal_stmt { $$= nullptr; }
|restart_server_stmt 
|revoke { $$= nullptr; }
|rollback { $$= nullptr; }
|savepoint { $$= nullptr; }
|select_stmt 
|set { $$= nullptr; CONTEXTUALIZE($1); }
|set_resource_group_stmt 
|set_role_stmt 
|show_binary_log_status_stmt 
|show_binary_logs_stmt 
|show_binlog_events_stmt 
|show_character_set_stmt 
|show_collation_stmt 
|show_columns_stmt 
|show_count_errors_stmt 
|show_count_warnings_stmt 
|show_create_database_stmt 
|show_create_event_stmt 
|show_create_function_stmt 
|show_create_procedure_stmt 
|show_create_table_stmt 
|show_create_trigger_stmt 
|show_create_user_stmt 
|show_create_view_stmt 
|show_databases_stmt 
|show_engine_logs_stmt 
|show_engine_mutex_stmt 
|show_engine_status_stmt 
|show_engines_stmt 
|show_errors_stmt 
|show_events_stmt 
|show_function_code_stmt 
|show_function_status_stmt 
|show_grants_stmt 
|show_keys_stmt 
|show_open_tables_stmt 
|show_parse_tree_stmt 
|show_plugins_stmt 
|show_privileges_stmt 
|show_procedure_code_stmt 
|show_procedure_status_stmt 
|show_processlist_stmt 
|show_profile_stmt 
|show_profiles_stmt 
|show_relaylog_events_stmt 
|show_replica_status_stmt 
|show_replicas_stmt 
|show_status_stmt 
|show_table_status_stmt 
|show_tables_stmt 
|show_triggers_stmt 
|show_variables_stmt 
|show_warnings_stmt 
|shutdown_stmt 
|signal_stmt { $$= nullptr; }
|start { $$= nullptr; }
|start_replica_stmt { $$= nullptr; }
|stop_replica_stmt { $$= nullptr; }
|truncate_stmt 
|uninstall { $$= nullptr; }
|unlock { $$= nullptr; }
|update_stmt 
|use { $$= nullptr; }
|xa { $$= nullptr; }
;

deallocate:
deallocate_or_drop PREPARE_SYM ident {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->sql_command= SQLCOM_DEALLOCATE_PREPARE;
            lex->prepared_stmt_name= to_lex_cstring($3);
          }
;

deallocate_or_drop:
DEALLOCATE_SYM 
|DROP 
;

prepare:
PREPARE_SYM ident FROM prepare_src {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->sql_command= SQLCOM_PREPARE;
            lex->prepared_stmt_name= to_lex_cstring($2);
            
            lex->contains_plaintext_password= true;
          }
;

prepare_src:
TEXT_STRING_sys {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->prepared_stmt_code= $1;
            lex->prepared_stmt_code_is_varref= false;
          }
|'@' ident_or_text {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->prepared_stmt_code= $2;
            lex->prepared_stmt_code_is_varref= true;
          }
;

execute:
EXECUTE_SYM ident {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->sql_command= SQLCOM_EXECUTE;
            lex->prepared_stmt_name= to_lex_cstring($2);
          }execute_using {}
;

execute_using:
%empty 
|USING execute_var_list 
;

execute_var_list:
execute_var_list ',' execute_var_ident 
|execute_var_ident 
;

execute_var_ident:
'@' ident_or_text {
            LEX *lex=Lex;
            LEX_STRING *lexstr= (LEX_STRING*)sql_memdup(&$2, sizeof(LEX_STRING));
            if (!lexstr || lex->prepared_stmt_params.push_back(lexstr))
              MYSQL_YYABORT;
          }
;

help:
HELP_SYM {
            if (Lex->sphead)
            {
              my_error(ER_SP_BADSTATEMENT, MYF(0), "HELP");
              MYSQL_YYABORT;
            }
          }ident_or_text {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_HELP;
            lex->help_arg= $3.str;
          }
;

change_replication_stmt:
CHANGE REPLICATION SOURCE_SYM TO_SYM {
            LEX *lex = Lex;
            lex->sql_command = SQLCOM_CHANGE_REPLICATION_SOURCE;
            
            assert(Lex->mi.repl_ignore_server_ids.empty());
            lex->mi.set_unspecified();
          }source_defs opt_channel {
            if (Lex->set_channel_name($7))
              MYSQL_YYABORT;  
          }
|CHANGE REPLICATION FILTER_SYM {
            THD *thd= YYTHD;
            LEX* lex= thd->lex;
            assert(lex->m_sql_cmd == nullptr);
            lex->sql_command = SQLCOM_CHANGE_REPLICATION_FILTER;
            lex->m_sql_cmd= NEW_PTN Sql_cmd_change_repl_filter();
            if (lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
          }filter_defs opt_channel {
            if (Lex->set_channel_name($6))
              MYSQL_YYABORT;  
          }
;

filter_defs:
filter_def 
|filter_defs ',' filter_def 
;

filter_def:
REPLICATE_DO_DB EQ opt_filter_db_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3, OPT_REPLICATE_DO_DB);
          }
|REPLICATE_IGNORE_DB EQ opt_filter_db_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3, OPT_REPLICATE_IGNORE_DB);
          }
|REPLICATE_DO_TABLE EQ opt_filter_table_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3, OPT_REPLICATE_DO_TABLE);
          }
|REPLICATE_IGNORE_TABLE EQ opt_filter_table_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3, OPT_REPLICATE_IGNORE_TABLE);
          }
|REPLICATE_WILD_DO_TABLE EQ opt_filter_string_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3, OPT_REPLICATE_WILD_DO_TABLE);
          }
|REPLICATE_WILD_IGNORE_TABLE EQ opt_filter_string_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3,
                                             OPT_REPLICATE_WILD_IGNORE_TABLE);
          }
|REPLICATE_REWRITE_DB EQ opt_filter_db_pair_list {
            Sql_cmd_change_repl_filter * filter_sql_cmd=
              (Sql_cmd_change_repl_filter*) Lex->m_sql_cmd;
            assert(filter_sql_cmd != nullptr);
            filter_sql_cmd->set_filter_value($3, OPT_REPLICATE_REWRITE_DB);
          }
;

opt_filter_db_list:
'(' ')' {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|'(' filter_db_list ')' {
            $$= $2;
          }
;

filter_db_list:
filter_db_ident {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
|filter_db_list ',' filter_db_ident {
            $1->push_back($3);
            $$= $1;
          }
;

filter_db_ident:
ident {
            THD *thd= YYTHD;
            Item *db_item= NEW_PTN Item_string($1.str, $1.length,
                                               thd->charset());
            $$= db_item;
          }
;

opt_filter_db_pair_list:
'(' ')' {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|'(' filter_db_pair_list ')' {
            $$= $2;
          }
;

filter_db_pair_list:
'(' filter_db_ident ',' filter_db_ident ')' {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($2);
            $$->push_back($4);
          }
|filter_db_pair_list ',' '(' filter_db_ident ',' filter_db_ident ')' {
            $1->push_back($4);
            $1->push_back($6);
            $$= $1;
          }
;

opt_filter_table_list:
'(' ')' {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|'(' filter_table_list ')' {
            $$= $2;
          }
;

filter_table_list:
filter_table_ident {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
|filter_table_list ',' filter_table_ident {
            $1->push_back($3);
            $$= $1;
          }
;

filter_table_ident:
schema '.' ident {
            THD *thd= YYTHD;
            Item_string *table_item= NEW_PTN Item_string($1.str, $1.length,
                                                         thd->charset());
            table_item->append(thd->strmake(".", 1), 1);
            table_item->append($3.str, $3.length);
            $$= table_item;
          }
;

opt_filter_string_list:
'(' ')' {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|'(' filter_string_list ')' {
            $$= $2;
          }
;

filter_string_list:
filter_string {
            $$= NEW_PTN mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
|filter_string_list ',' filter_string {
            $1->push_back($3);
            $$= $1;
          }
;

filter_string:
filter_wild_db_table_string {
            THD *thd= YYTHD;
            Item *string_item= NEW_PTN Item_string($1.str, $1.length,
                                                   thd->charset());
            $$= string_item;
          }
;

source_defs:
source_def 
|source_defs ',' source_def 
;

source_def:
SOURCE_HOST_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.host = $3.str;
          }
|NETWORK_NAMESPACE_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.network_namespace = $3.str;
          }
|SOURCE_BIND_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.bind_addr = $3.str;
          }
|SOURCE_USER_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.user = $3.str;
          }
|SOURCE_PASSWORD_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.password = $3.str;
            if (strlen($3.str) > 32)
            {
              my_error(ER_CHANGE_SOURCE_PASSWORD_LENGTH, MYF(0));
              MYSQL_YYABORT;
            }
            Lex->contains_plaintext_password= true;
          }
|SOURCE_PORT_SYM EQ ulong_num {
            Lex->mi.port = $3;
          }
|SOURCE_CONNECT_RETRY_SYM EQ ulong_num {
            Lex->mi.connect_retry = $3;
          }
|SOURCE_RETRY_COUNT_SYM EQ ulong_num {
            Lex->mi.retry_count= $3;
            Lex->mi.retry_count_opt= LEX_SOURCE_INFO::LEX_MI_ENABLE;
          }
|SOURCE_DELAY_SYM EQ ulong_num {
            if ($3 > SOURCE_DELAY_MAX)
            {
              const char *msg= YYTHD->strmake(@3.cpp.start, @3.cpp.end - @3.cpp.start);
              my_error(ER_SOURCE_DELAY_VALUE_OUT_OF_RANGE, MYF(0),
                       msg, SOURCE_DELAY_MAX);
            }
            else
              Lex->mi.sql_delay = $3;
          }
|SOURCE_SSL_SYM EQ ulong_num {
            Lex->mi.ssl= $3 ?
              LEX_SOURCE_INFO::LEX_MI_ENABLE : LEX_SOURCE_INFO::LEX_MI_DISABLE;
          }
|SOURCE_SSL_CA_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_ca= $3.str;
          }
|SOURCE_SSL_CAPATH_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_capath= $3.str;
          }
|SOURCE_TLS_VERSION_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.tls_version= $3.str;
          }
|SOURCE_TLS_CIPHERSUITES_SYM EQ source_tls_ciphersuites_def 
|SOURCE_SSL_CERT_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_cert= $3.str;
          }
|SOURCE_SSL_CIPHER_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_cipher= $3.str;
          }
|SOURCE_SSL_KEY_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_key= $3.str;
          }
|SOURCE_SSL_VERIFY_SERVER_CERT_SYM EQ ulong_num {
            Lex->mi.ssl_verify_server_cert= $3 ?
              LEX_SOURCE_INFO::LEX_MI_ENABLE : LEX_SOURCE_INFO::LEX_MI_DISABLE;
          }
|SOURCE_SSL_CRL_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_crl= $3.str;
          }
|SOURCE_SSL_CRLPATH_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.ssl_crlpath= $3.str;
          }
|SOURCE_PUBLIC_KEY_PATH_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.public_key_path= $3.str;
          }
|GET_SOURCE_PUBLIC_KEY_SYM EQ ulong_num {
            Lex->mi.get_public_key= $3 ?
              LEX_SOURCE_INFO::LEX_MI_ENABLE :
              LEX_SOURCE_INFO::LEX_MI_DISABLE;
          }
|SOURCE_HEARTBEAT_PERIOD_SYM EQ NUM_literal {
            Item *num= $3;
            ITEMIZE(num, &num);

            Lex->mi.heartbeat_period= (float) num->val_real();
            if (Lex->mi.heartbeat_period > REPLICA_MAX_HEARTBEAT_PERIOD ||
                Lex->mi.heartbeat_period < 0.0)
            {
               const char format[]= "%d";
               char buf[4*sizeof(REPLICA_MAX_HEARTBEAT_PERIOD) + sizeof(format)];
               sprintf(buf, format, REPLICA_MAX_HEARTBEAT_PERIOD);
               my_error(ER_REPLICA_HEARTBEAT_VALUE_OUT_OF_RANGE, MYF(0), buf);
               MYSQL_YYABORT;
            }
            if (Lex->mi.heartbeat_period > replica_net_timeout)
            {
              push_warning(YYTHD, Sql_condition::SL_WARNING,
                           ER_REPLICA_HEARTBEAT_VALUE_OUT_OF_RANGE_MAX,
                           ER_THD(YYTHD, ER_REPLICA_HEARTBEAT_VALUE_OUT_OF_RANGE_MAX));
            }
            if (Lex->mi.heartbeat_period < 0.001)
            {
              if (Lex->mi.heartbeat_period != 0.0)
              {
                push_warning(YYTHD, Sql_condition::SL_WARNING,
                             ER_REPLICA_HEARTBEAT_VALUE_OUT_OF_RANGE_MIN,
                             ER_THD(YYTHD, ER_REPLICA_HEARTBEAT_VALUE_OUT_OF_RANGE_MIN));
                Lex->mi.heartbeat_period= 0.0;
              }
              Lex->mi.heartbeat_opt=  LEX_SOURCE_INFO::LEX_MI_DISABLE;
            }
            Lex->mi.heartbeat_opt=  LEX_SOURCE_INFO::LEX_MI_ENABLE;
          }
|IGNORE_SERVER_IDS_SYM EQ '(' ignore_server_id_list ')' {
            Lex->mi.repl_ignore_server_ids_opt= LEX_SOURCE_INFO::LEX_MI_ENABLE;
           }
|SOURCE_COMPRESSION_ALGORITHM_SYM EQ TEXT_STRING_sys {
            Lex->mi.compression_algorithm = $3.str;
           }
|SOURCE_ZSTD_COMPRESSION_LEVEL_SYM EQ ulong_num {
            Lex->mi.zstd_compression_level = $3;
           }
|SOURCE_AUTO_POSITION_SYM EQ ulong_num {
            Lex->mi.auto_position= $3 ?
              LEX_SOURCE_INFO::LEX_MI_ENABLE :
              LEX_SOURCE_INFO::LEX_MI_DISABLE;
          }
|PRIVILEGE_CHECKS_USER_SYM EQ privilege_check_def 
|REQUIRE_ROW_FORMAT_SYM EQ ulong_num {
            switch($3) {
            case 0:
                Lex->mi.require_row_format =
                  LEX_SOURCE_INFO::LEX_MI_DISABLE;
                break;
            case 1:
                Lex->mi.require_row_format =
                  LEX_SOURCE_INFO::LEX_MI_ENABLE;
                break;
            default:
              const char* wrong_value = YYTHD->strmake(@3.raw.start, @3.raw.length());
              my_error(ER_REQUIRE_ROW_FORMAT_INVALID_VALUE, MYF(0), wrong_value);
            }
          }
|REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYM EQ table_primary_key_check_def 
|SOURCE_CONNECTION_AUTO_FAILOVER_SYM EQ real_ulong_num {
            switch($3) {
            case 0:
                Lex->mi.m_source_connection_auto_failover =
                  LEX_SOURCE_INFO::LEX_MI_DISABLE;
                break;
            case 1:
                Lex->mi.m_source_connection_auto_failover =
                  LEX_SOURCE_INFO::LEX_MI_ENABLE;
                break;
            default:
                YYTHD->syntax_error_at(@3);
                MYSQL_YYABORT;
            }
          }
|ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS_SYM EQ assign_gtids_to_anonymous_transactions_def 
|GTID_ONLY_SYM EQ real_ulong_num {
            switch($3) {
            case 0:
                Lex->mi.m_gtid_only =
                  LEX_SOURCE_INFO::LEX_MI_DISABLE;
                break;
            case 1:
                Lex->mi.m_gtid_only =
                  LEX_SOURCE_INFO::LEX_MI_ENABLE;
                break;
            default:
                YYTHD->syntax_error_at(@3,
                  "You have an error in your CHANGE REPLICATION SOURCE syntax; GTID_ONLY only accepts values 0 or 1");
                MYSQL_YYABORT;
            }
          }
|source_file_def 
;

ignore_server_id_list:
%empty 
|ignore_server_id 
|ignore_server_id_list ',' ignore_server_id 
;

ignore_server_id:
ulong_num {
            Lex->mi.repl_ignore_server_ids.push_back($1);
          }

privilege_check_def:
user_ident_or_text {
            Lex->mi.privilege_checks_none= false;
            Lex->mi.privilege_checks_username= $1->user.str;
            Lex->mi.privilege_checks_hostname= $1->host.str;
          }
|NULL_SYM {
            Lex->mi.privilege_checks_none= true;
            Lex->mi.privilege_checks_username= nullptr;
            Lex->mi.privilege_checks_hostname= nullptr;
          }
;

table_primary_key_check_def:
STREAM_SYM {
            Lex->mi.require_table_primary_key_check= LEX_SOURCE_INFO::LEX_MI_PK_CHECK_STREAM;
          }
|ON_SYM {
            Lex->mi.require_table_primary_key_check= LEX_SOURCE_INFO::LEX_MI_PK_CHECK_ON;
          }
|OFF_SYM {
            Lex->mi.require_table_primary_key_check= LEX_SOURCE_INFO::LEX_MI_PK_CHECK_OFF;
          }
|GENERATE_SYM {
            Lex->mi.require_table_primary_key_check= LEX_SOURCE_INFO::LEX_MI_PK_CHECK_GENERATE;
          }
;

assign_gtids_to_anonymous_transactions_def:
OFF_SYM {
            Lex->mi.assign_gtids_to_anonymous_transactions_type = LEX_SOURCE_INFO::LEX_MI_ANONYMOUS_TO_GTID_OFF;
          }
|LOCAL_SYM {
            Lex->mi.assign_gtids_to_anonymous_transactions_type = LEX_SOURCE_INFO::LEX_MI_ANONYMOUS_TO_GTID_LOCAL;
          }
|TEXT_STRING {
            Lex->mi.assign_gtids_to_anonymous_transactions_type = LEX_SOURCE_INFO::LEX_MI_ANONYMOUS_TO_GTID_UUID;
            Lex->mi.assign_gtids_to_anonymous_transactions_manual_uuid = $1.str;
            if (!mysql::gtid::Uuid::is_valid($1.str, mysql::gtid::Uuid::TEXT_LENGTH))
            {
              my_error(ER_WRONG_VALUE, MYF(0), "UUID", $1.str);
              MYSQL_YYABORT;
            }
          }
;

source_tls_ciphersuites_def:
TEXT_STRING_sys_nonewline {
            Lex->mi.tls_ciphersuites = LEX_SOURCE_INFO::SPECIFIED_STRING;
            Lex->mi.tls_ciphersuites_string= $1.str;
          }
|NULL_SYM {
            Lex->mi.tls_ciphersuites = LEX_SOURCE_INFO::SPECIFIED_NULL;
            Lex->mi.tls_ciphersuites_string = nullptr;
          }
;

source_file_def:
SOURCE_LOG_FILE_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.log_file_name = $3.str;
          }
|SOURCE_LOG_POS_SYM EQ ulonglong_num {
            Lex->mi.pos = $3;
            
            Lex->mi.pos = max<ulonglong>(BIN_LOG_HEADER_SIZE, Lex->mi.pos);
          }
|RELAY_LOG_FILE_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->mi.relay_log_name = $3.str;
          }
|RELAY_LOG_POS_SYM EQ ulong_num {
            Lex->mi.relay_log_pos = $3;
            
            Lex->mi.relay_log_pos = max<ulong>(BIN_LOG_HEADER_SIZE,
                                               Lex->mi.relay_log_pos);
          }
;

opt_channel:
%empty { $$ = {}; }
|FOR_SYM CHANNEL_SYM TEXT_STRING_sys_nonewline { $$ = to_lex_cstring($3); }
;

create_table_stmt:
CREATE opt_temporary TABLE_SYM opt_if_not_exists table_ident '(' table_element_list ')' opt_create_table_options_etc {
            $$= NEW_PTN PT_create_table_stmt(@$, YYMEM_ROOT, $2, $4, $5,
                                             $7,
                                             $9.opt_create_table_options,
                                             $9.opt_partitioning,
                                             $9.on_duplicate,
                                             $9.opt_query_expression);
          }
|CREATE opt_temporary TABLE_SYM opt_if_not_exists table_ident opt_create_table_options_etc {
            $$= NEW_PTN PT_create_table_stmt(@$, YYMEM_ROOT, $2, $4, $5,
                                             nullptr,
                                             $6.opt_create_table_options,
                                             $6.opt_partitioning,
                                             $6.on_duplicate,
                                             $6.opt_query_expression);
          }
|CREATE opt_temporary TABLE_SYM opt_if_not_exists table_ident LIKE table_ident {
            $$= NEW_PTN PT_create_table_stmt(@$, YYMEM_ROOT, $2, $4, $5, $7);
          }
|CREATE opt_temporary TABLE_SYM opt_if_not_exists table_ident '(' LIKE table_ident ')' {
            $$= NEW_PTN PT_create_table_stmt(@$, YYMEM_ROOT, $2, $4, $5, $8);
          }
;

create_role_stmt:
CREATE ROLE_SYM opt_if_not_exists role_list {
            $$= NEW_PTN PT_create_role(@$, !!$3, $4);
          }
;

create_resource_group_stmt:
CREATE RESOURCE_SYM GROUP_SYM ident TYPE_SYM opt_equal resource_group_types opt_resource_group_vcpu_list opt_resource_group_priority opt_resource_group_enable_disable {
            $$= NEW_PTN PT_create_resource_group(@$, to_lex_cstring($4), $7, $8, $9,
                                                 $10.is_default ? true :
                                                 $10.value);
          }
;

create:
CREATE DATABASE opt_if_not_exists ident {
            Lex->create_info= YYTHD->alloc_typed<HA_CREATE_INFO>();
            if (Lex->create_info == nullptr)
              MYSQL_YYABORT; 
            Lex->create_info->default_table_charset= nullptr;
            Lex->create_info->used_fields= 0;
          }opt_create_database_options {
            LEX *lex=Lex;
            lex->sql_command=SQLCOM_CREATE_DB;
            lex->name= $4;
            lex->create_info->options= $3 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
          }
|CREATE view_or_trigger_or_sp_or_event {}
|CREATE USER opt_if_not_exists create_user_list default_role_clause require_clause connect_options opt_account_lock_password_expire_options opt_user_attribute {
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_CREATE_USER;
            lex->default_roles= $5;
            Lex->create_info= YYTHD->alloc_typed<HA_CREATE_INFO>();
            if (Lex->create_info == nullptr)
              MYSQL_YYABORT; 
            lex->create_info->options= $3 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
            MAKE_CMD_DCL_DUMMY();
          }
|CREATE LOGFILE_SYM GROUP_SYM ident ADD lg_undofile opt_logfile_group_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($7 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $7))
                MYSQL_YYABORT; 
            }

            Lex->m_sql_cmd= NEW_PTN Sql_cmd_logfile_group{CREATE_LOGFILE_GROUP,
                                                          $4, pc, $6};
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT;  

            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
|CREATE TABLESPACE_SYM ident opt_ts_datafile_name opt_logfile_group_name opt_tablespace_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($6 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $6))
                MYSQL_YYABORT;
            }

            auto cmd= NEW_PTN Sql_cmd_create_tablespace{$3, $4, $5, pc};
            if (!cmd)
              MYSQL_YYABORT;  
            Lex->m_sql_cmd= cmd;
            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
|CREATE UNDO_SYM TABLESPACE_SYM ident ADD ts_datafile opt_undo_tablespace_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT; 

            if ($7 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $7))
                MYSQL_YYABORT;
            }

            auto cmd= NEW_PTN Sql_cmd_create_undo_tablespace{
              CREATE_UNDO_TABLESPACE, $4, $6, pc};
            if (!cmd)
              MYSQL_YYABORT; 
            Lex->m_sql_cmd= cmd;
            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
|CREATE SERVER_SYM ident_or_text FOREIGN DATA_SYM WRAPPER_SYM ident_or_text OPTIONS_SYM '(' server_options_list ')' {
            Lex->sql_command= SQLCOM_CREATE_SERVER;
            if ($3.length == 0)
            {
              my_error(ER_WRONG_VALUE, MYF(0), "server name", "");
              MYSQL_YYABORT;
            }
            Lex->server_options.m_server_name= $3;
            Lex->server_options.set_scheme($7);
            Lex->m_sql_cmd=
              NEW_PTN Sql_cmd_create_server(&Lex->server_options);
          }
;

create_srs_stmt:
CREATE OR_SYM REPLACE_SYM SPATIAL_SYM REFERENCE_SYM SYSTEM_SYM real_ulonglong_num srs_attributes {
            $$= NEW_PTN PT_create_srs(@$, $7, *$8, true, false);
          }
|CREATE SPATIAL_SYM REFERENCE_SYM SYSTEM_SYM opt_if_not_exists real_ulonglong_num srs_attributes {
            $$= NEW_PTN PT_create_srs(@$, $6, *$7, false, $5);
          }
;

srs_attributes:
%empty {
            $$ = NEW_PTN Sql_cmd_srs_attributes();
            if (!$$)
              MYSQL_YYABORT_ERROR(ER_DA_OOM, MYF(0)); 
          }
|srs_attributes NAME_SYM TEXT_STRING_sys_nonewline {
            if ($1->srs_name.str != nullptr)
            {
              MYSQL_YYABORT_ERROR(ER_SRS_MULTIPLE_ATTRIBUTE_DEFINITIONS, MYF(0),
                                  "NAME");
            }
            else
            {
              $1->srs_name= $3;
            }
          }
|srs_attributes DEFINITION_SYM TEXT_STRING_sys_nonewline {
            if ($1->definition.str != nullptr)
            {
              MYSQL_YYABORT_ERROR(ER_SRS_MULTIPLE_ATTRIBUTE_DEFINITIONS, MYF(0),
                                  "DEFINITION");
            }
            else
            {
              $1->definition= $3;
            }
          }
|srs_attributes ORGANIZATION_SYM TEXT_STRING_sys_nonewline IDENTIFIED_SYM BY real_ulonglong_num {
            if ($1->organization.str != nullptr)
            {
              MYSQL_YYABORT_ERROR(ER_SRS_MULTIPLE_ATTRIBUTE_DEFINITIONS, MYF(0),
                                  "ORGANIZATION");
            }
            else
            {
              $1->organization= $3;
              $1->organization_coordsys_id= $6;
            }
          }
|srs_attributes DESCRIPTION_SYM TEXT_STRING_sys_nonewline {
            if ($1->description.str != nullptr)
            {
              MYSQL_YYABORT_ERROR(ER_SRS_MULTIPLE_ATTRIBUTE_DEFINITIONS, MYF(0),
                                  "DESCRIPTION");
            }
            else
            {
              $1->description= $3;
            }
          }
;

default_role_clause:
%empty {
            $$= nullptr;
          }
|DEFAULT_SYM ROLE_SYM role_list {
            $$= $3;
          }
;

create_index_stmt:
CREATE opt_unique INDEX_SYM ident opt_index_type_clause ON_SYM table_ident '(' key_list_with_expression ')' opt_index_options opt_index_lock_and_algorithm {
            $$= NEW_PTN PT_create_index_stmt(@$, YYMEM_ROOT, $2, $4, $5,
                                             $7, $9, $11,
                                             $12.algo.get_or_default(),
                                             $12.lock.get_or_default());
          }
|CREATE FULLTEXT_SYM INDEX_SYM ident ON_SYM table_ident '(' key_list_with_expression ')' opt_fulltext_index_options opt_index_lock_and_algorithm {
            $$= NEW_PTN PT_create_index_stmt(@$, YYMEM_ROOT, KEYTYPE_FULLTEXT, $4,
                                             nullptr, $6, $8, $10,
                                             $11.algo.get_or_default(),
                                             $11.lock.get_or_default());
          }
|CREATE SPATIAL_SYM INDEX_SYM ident ON_SYM table_ident '(' key_list_with_expression ')' opt_spatial_index_options opt_index_lock_and_algorithm {
            $$= NEW_PTN PT_create_index_stmt(@$, YYMEM_ROOT, KEYTYPE_SPATIAL, $4,
                                             nullptr, $6, $8, $10,
                                             $11.algo.get_or_default(),
                                             $11.lock.get_or_default());
          }
;

server_options_list:
server_option 
|server_options_list ',' server_option 
;

server_option:
USER TEXT_STRING_sys {
            Lex->server_options.set_username($2);
          }
|HOST_SYM TEXT_STRING_sys {
            Lex->server_options.set_host($2);
          }
|DATABASE TEXT_STRING_sys {
            Lex->server_options.set_db($2);
          }
|OWNER_SYM TEXT_STRING_sys {
            Lex->server_options.set_owner($2);
          }
|PASSWORD TEXT_STRING_sys {
            Lex->server_options.set_password($2);
            Lex->contains_plaintext_password= true;
          }
|SOCKET_SYM TEXT_STRING_sys {
            Lex->server_options.set_socket($2);
          }
|PORT_SYM ulong_num {
            Lex->server_options.set_port($2);
          }
;

event_tail:
EVENT_SYM opt_if_not_exists sp_name {
            THD *thd= YYTHD;
            LEX *lex=Lex;

            lex->stmt_definition_begin= @1.cpp.start;
            lex->create_info->options= $2 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
            if (!(lex->event_parse_data= new (thd->mem_root) Event_parse_data()))
              MYSQL_YYABORT;
            lex->event_parse_data->identifier= $3;
            lex->event_parse_data->on_completion=
                                  Event_parse_data::ON_COMPLETION_DROP;

            lex->sql_command= SQLCOM_CREATE_EVENT;
            
            MAKE_CMD_DDL_DUMMY();
          }ON_SYM SCHEDULE_SYM ev_schedule_time opt_ev_on_completion opt_ev_status opt_ev_comment DO_SYM ev_sql_stmt {
            
            Lex->sql_command= SQLCOM_CREATE_EVENT;
            assert(Lex->m_sql_cmd->sql_cmd_type() == SQL_CMD_DDL);
            assert(Lex->m_sql_cmd->sql_command_code() == SQLCOM_CREATE_EVENT);
          }
;

ev_schedule_time:
EVERY_SYM expr interval {
            ITEMIZE($2, &$2);

            Lex->event_parse_data->item_expression= $2;
            Lex->event_parse_data->interval= $3;
          }ev_starts ev_ends 
|AT_SYM expr {
            ITEMIZE($2, &$2);

            Lex->event_parse_data->item_execute_at= $2;
          }
;

opt_ev_status:
%empty { $$= 0; }
|ENABLE_SYM {
            Lex->event_parse_data->status= Event_parse_data::ENABLED;
            Lex->event_parse_data->status_changed= true;
            $$= 1;
          }
|DISABLE_SYM ON_SYM SLAVE {
            push_deprecated_warn(YYTHD, "<CREATE|ALTER> EVENT ... DISABLE ON SLAVE",
                                        "<CREATE|ALTER> EVENT ... DISABLE ON REPLICA");
            Lex->event_parse_data->status= Event_parse_data::REPLICA_SIDE_DISABLED;
            Lex->event_parse_data->status_changed= true;
            $$= 1;
          }
|DISABLE_SYM ON_SYM REPLICA_SYM {
            Lex->event_parse_data->status= Event_parse_data::REPLICA_SIDE_DISABLED;
            Lex->event_parse_data->status_changed= true;
            $$= 1;
          }
|DISABLE_SYM {
            Lex->event_parse_data->status= Event_parse_data::DISABLED;
            Lex->event_parse_data->status_changed= true;
            $$= 1;
          }
;

ev_starts:
%empty {
            Item *item= NEW_PTN Item_func_now_local(0);
            if (item == nullptr)
              MYSQL_YYABORT;
            Lex->event_parse_data->item_starts= item;
          }
|STARTS_SYM expr {
            ITEMIZE($2, &$2);

            Lex->event_parse_data->item_starts= $2;
          }
;

ev_ends:
%empty 
|ENDS_SYM expr {
            ITEMIZE($2, &$2);

            Lex->event_parse_data->item_ends= $2;
          }
;

opt_ev_on_completion:
%empty { $$= 0; }
|ev_on_completion 
;

ev_on_completion:
ON_SYM COMPLETION_SYM PRESERVE_SYM {
            Lex->event_parse_data->on_completion=
                                  Event_parse_data::ON_COMPLETION_PRESERVE;
            $$= 1;
          }
|ON_SYM COMPLETION_SYM NOT_SYM PRESERVE_SYM {
            Lex->event_parse_data->on_completion=
                                  Event_parse_data::ON_COMPLETION_DROP;
            $$= 1;
          }
;

opt_ev_comment:
%empty { $$= 0; }
|COMMENT_SYM TEXT_STRING_sys {
            Lex->event_parse_data->comment= $2;
            $$= 1;
          }
;

ev_sql_stmt:
{
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            
            if (lex->sphead)
            {
              my_error(ER_EVENT_RECURSION_FORBIDDEN, MYF(0));
              MYSQL_YYABORT;
            }

            sp_head *sp= sp_start_parsing(thd,
                                          enum_sp_type::EVENT,
                                          lex->event_parse_data->identifier);

            if (!sp)
              MYSQL_YYABORT;

            lex->sphead= sp;

            memset(&lex->sp_chistics, 0, sizeof(st_sp_chistics));
            sp->m_chistics= &lex->sp_chistics;

            
            lex->sp_chistics.language = {"SQL",3};

            
            sp->set_body_start(thd, @0.cpp.end);
          }ev_sql_stmt_inner {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            sp_finish_parsing(thd);

            lex->sp_chistics.suid= SP_IS_SUID;  
            lex->event_parse_data->body_changed= true;
          }
;

ev_sql_stmt_inner:
sp_proc_stmt_statement 
|sp_proc_stmt_return 
|sp_proc_stmt_if 
|case_stmt_specification 
|sp_labeled_block 
|sp_unlabeled_block 
|sp_labeled_control 
|sp_proc_stmt_unlabeled 
|sp_proc_stmt_leave 
|sp_proc_stmt_iterate 
|sp_proc_stmt_open 
|sp_proc_stmt_fetch 
|sp_proc_stmt_close 
;

sp_name:
ident '.' ident {
            if (!$1.str ||
                (check_and_convert_db_name(&$1, false) != Ident_name_check::OK))
              MYSQL_YYABORT;
            if (sp_check_name(&$3))
            {
              MYSQL_YYABORT;
            }
            $$= new (YYMEM_ROOT) sp_name(to_lex_cstring($1), $3, true);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->init_qname(YYTHD);
          }
|ident {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            LEX_CSTRING db;
            if (sp_check_name(&$1))
            {
              MYSQL_YYABORT;
            }
            if (lex->copy_db_to(&db.str, &db.length))
              MYSQL_YYABORT;
            $$= new (YYMEM_ROOT) sp_name(db, $1, false);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->init_qname(thd);
          }
;

sp_a_chistics:
%empty {}
|sp_a_chistics sp_chistic {}
;

sp_c_chistics:
%empty {}
|sp_c_chistics sp_c_chistic {}
;

sp_chistic:
COMMENT_SYM TEXT_STRING_sys { Lex->sp_chistics.comment= to_lex_cstring($2); }
|LANGUAGE_SYM SQL_SYM { Lex->sp_chistics.language= {"SQL",3}; }
|LANGUAGE_SYM ident { Lex->sp_chistics.language= to_lex_cstring($2); }
|NO_SYM SQL_SYM { Lex->sp_chistics.daccess= SP_NO_SQL; }
|CONTAINS_SYM SQL_SYM { Lex->sp_chistics.daccess= SP_CONTAINS_SQL; }
|READS_SYM SQL_SYM DATA_SYM { Lex->sp_chistics.daccess= SP_READS_SQL_DATA; }
|MODIFIES_SYM SQL_SYM DATA_SYM { Lex->sp_chistics.daccess= SP_MODIFIES_SQL_DATA; }
|sp_suid {}
;

sp_c_chistic:
sp_chistic { }
|DETERMINISTIC_SYM { Lex->sp_chistics.detistic= true; }
|not DETERMINISTIC_SYM { Lex->sp_chistics.detistic= false; }
;

sp_suid:
SQL_SYM SECURITY_SYM DEFINER_SYM {
            Lex->sp_chistics.suid= SP_IS_SUID;
          }
|SQL_SYM SECURITY_SYM INVOKER_SYM {
            Lex->sp_chistics.suid= SP_IS_NOT_SUID;
          }
;

call_stmt:
CALL_SYM sp_name opt_paren_expr_list {
            $$= NEW_PTN PT_call(@$, $2, $3);
          }
;

opt_paren_expr_list:
%empty { $$= nullptr; }
|'(' opt_expr_list ')' {
              $$= $2;
            }
;

sp_fdparam_list:
%empty 
|sp_fdparams 
;

sp_fdparams:
sp_fdparams ',' sp_fdparam 
|sp_fdparam 
;

sp_fdparam:
ident type opt_collate {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            CONTEXTUALIZE($2);
            enum_field_types field_type= $2->type;
            const CHARSET_INFO *cs= $2->get_charset();
            if (merge_sp_var_charset_and_collation(cs, $3, &cs))
              MYSQL_YYABORT;

            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            if (sp_check_name(&$1))
              MYSQL_YYABORT;

            if (pctx->find_variable($1.str, $1.length, true))
            {
              my_error(ER_SP_DUP_PARAM, MYF(0), $1.str);
              MYSQL_YYABORT;
            }

            sp_variable *spvar= pctx->add_variable(thd,
                                                   $1,
                                                   field_type,
                                                   sp_variable::MODE_IN);

            if (spvar->field_def.init(thd, "", field_type,
                                      $2->get_length(), $2->get_dec(),
                                      $2->get_type_flags(),
                                      nullptr, nullptr, &NULL_CSTR, nullptr,
                                      $2->get_interval_list(),
                                      cs ? cs : thd->variables.collation_database,
                                      $3 != nullptr, $2->get_uint_geom_type(),
                                      nullptr, nullptr, {},
                                      dd::Column::enum_hidden_type::HT_VISIBLE))
            {
              MYSQL_YYABORT;
            }

            if (prepare_sp_create_field(thd,
                                        &spvar->field_def))
            {
              MYSQL_YYABORT;
            }
            spvar->field_def.field_name= spvar->name.str;
            spvar->field_def.is_nullable= true;
          }
;

sp_pdparam_list:
%empty 
|sp_pdparams 
;

sp_pdparams:
sp_pdparams ',' sp_pdparam 
|sp_pdparam 
;

sp_pdparam:
sp_opt_inout ident type opt_collate {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            if (sp_check_name(&$2))
              MYSQL_YYABORT;

            if (pctx->find_variable($2.str, $2.length, true))
            {
              my_error(ER_SP_DUP_PARAM, MYF(0), $2.str);
              MYSQL_YYABORT;
            }

            CONTEXTUALIZE($3);
            enum_field_types field_type= $3->type;
            const CHARSET_INFO *cs= $3->get_charset();
            if (merge_sp_var_charset_and_collation(cs, $4, &cs))
              MYSQL_YYABORT;

            sp_variable *spvar= pctx->add_variable(thd,
                                                   $2,
                                                   field_type,
                                                   (sp_variable::enum_mode) $1);

            if (spvar->field_def.init(thd, "", field_type,
                                      $3->get_length(), $3->get_dec(),
                                      $3->get_type_flags(),
                                      nullptr, nullptr, &NULL_CSTR, nullptr,
                                      $3->get_interval_list(),
                                      cs ? cs : thd->variables.collation_database,
                                      $4 != nullptr, $3->get_uint_geom_type(),
                                      nullptr, nullptr, {},
                                      dd::Column::enum_hidden_type::HT_VISIBLE))
            {
              MYSQL_YYABORT;
            }

            if (prepare_sp_create_field(thd,
                                        &spvar->field_def))
            {
              MYSQL_YYABORT;
            }
            spvar->field_def.field_name= spvar->name.str;
            spvar->field_def.is_nullable= true;
          }
;

sp_opt_inout:
%empty { $$= sp_variable::MODE_IN; }
|IN_SYM { $$= sp_variable::MODE_IN; }
|OUT_SYM { $$= sp_variable::MODE_OUT; }
|INOUT_SYM { $$= sp_variable::MODE_INOUT; }
;

sp_proc_stmts:
%empty {}
|sp_proc_stmts sp_proc_stmt ';' 
;

sp_proc_stmts1:
sp_proc_stmt ';' {}
|sp_proc_stmts1 sp_proc_stmt ';' 
;

sp_decls:
%empty {
            $$.vars= $$.conds= $$.hndlrs= $$.curs= 0;
          }
|sp_decls sp_decl ';' {
            
            if (($2.vars || $2.conds) && ($1.curs || $1.hndlrs))
            { 
              my_error(ER_SP_VARCOND_AFTER_CURSHNDLR, MYF(0));
              MYSQL_YYABORT;
            }
            if ($2.curs && $1.hndlrs)
            { 
              my_error(ER_SP_CURSOR_AFTER_HANDLER, MYF(0));
              MYSQL_YYABORT;
            }
            $$.vars= $1.vars + $2.vars;
            $$.conds= $1.conds + $2.conds;
            $$.hndlrs= $1.hndlrs + $2.hndlrs;
            $$.curs= $1.curs + $2.curs;
          }
;

sp_decl:
DECLARE_SYM sp_decl_idents type opt_collate sp_opt_default {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp->reset_lex(thd);
            lex= thd->lex;

            pctx->declare_var_boundary($2);

            CONTEXTUALIZE($3);
            enum enum_field_types var_type= $3->type;
            const CHARSET_INFO *cs= $3->get_charset();
            if (merge_sp_var_charset_and_collation(cs, $4, &cs))
              MYSQL_YYABORT;

            uint num_vars= pctx->context_var_count();
            Item *dflt_value_item= $5.expr;

            LEX_CSTRING dflt_value_query= EMPTY_CSTR;

            if (dflt_value_item)
            {
              ITEMIZE(dflt_value_item, &dflt_value_item);
              const char *expr_start_ptr= $5.expr_start;
              if (lex->is_metadata_used())
              {
                dflt_value_query= make_string(thd, expr_start_ptr,
                                              @5.raw.end);
                if (!dflt_value_query.str)
                  MYSQL_YYABORT;
              }
            }
            else
            {
              dflt_value_item= NEW_PTN Item_null();

              if (dflt_value_item == nullptr)
                MYSQL_YYABORT;
            }

            
            

            for (uint i = num_vars-$2 ; i < num_vars ; i++)
            {
              uint var_idx= pctx->var_context2runtime(i);
              sp_variable *spvar= pctx->find_variable(var_idx);

              if (!spvar)
                MYSQL_YYABORT;

              spvar->type= var_type;
              spvar->default_value= dflt_value_item;

              if (spvar->field_def.init(thd, "", var_type,
                                        $3->get_length(), $3->get_dec(),
                                        $3->get_type_flags(),
                                        nullptr, nullptr, &NULL_CSTR, nullptr,
                                        $3->get_interval_list(),
                                        cs ? cs : thd->variables.collation_database,
                                        $4 != nullptr, $3->get_uint_geom_type(),
                                        nullptr, nullptr, {},
                                        dd::Column::enum_hidden_type::HT_VISIBLE))
              {
                MYSQL_YYABORT;
              }

              if (prepare_sp_create_field(thd, &spvar->field_def))
                MYSQL_YYABORT;

              spvar->field_def.field_name= spvar->name.str;
              spvar->field_def.is_nullable= true;

              

              sp_instr_set *is= NEW_PTN sp_instr_set(sp->instructions(),
                                                     lex,
                                                     var_idx,
                                                     dflt_value_item,
                                                     dflt_value_query,
                                                     (i == num_vars - 1));

              if (!is || sp->add_instr(thd, is))
                MYSQL_YYABORT;
            }

            pctx->declare_var_boundary(0);
            if (sp->restore_lex(thd))
              MYSQL_YYABORT;
            $$.vars= $2;
            $$.conds= $$.hndlrs= $$.curs= 0;
          }
|DECLARE_SYM ident CONDITION_SYM FOR_SYM sp_cond {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            if (pctx->find_condition($2, true))
            {
              my_error(ER_SP_DUP_COND, MYF(0), $2.str);
              MYSQL_YYABORT;
            }
            if(pctx->add_condition(thd, $2, $5))
              MYSQL_YYABORT;
            lex->keep_diagnostics= DA_KEEP_DIAGNOSTICS; 
            $$.vars= $$.hndlrs= $$.curs= 0;
            $$.conds= 1;
          }
|DECLARE_SYM sp_handler_type HANDLER_SYM FOR_SYM {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp_pcontext *parent_pctx= lex->get_sp_current_parsing_ctx();

            sp_pcontext *handler_pctx=
              parent_pctx->push_context(thd, sp_pcontext::HANDLER_SCOPE);

            sp_handler *h=
              parent_pctx->add_handler(thd, (sp_handler::enum_type) $2);

            lex->set_sp_current_parsing_ctx(handler_pctx);

            sp_instr_hpush_jump *i=
              NEW_PTN sp_instr_hpush_jump(sp->instructions(), handler_pctx, h);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;

            if ($2 == sp_handler::CONTINUE)
            {
              

              if (sp->m_parser_data.add_backpatch_entry(
                    i, handler_pctx->last_label()))
              {
                MYSQL_YYABORT;
              }
            }

            if (sp->m_parser_data.add_backpatch_entry(
                  i, handler_pctx->push_label(thd, EMPTY_CSTR, 0)))
            {
              MYSQL_YYABORT;
            }

            lex->keep_diagnostics= DA_KEEP_DIAGNOSTICS; 
          }sp_hcond_list sp_proc_stmt {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *hlab= pctx->pop_label(); 

            if ($2 == sp_handler::CONTINUE)
            {
              sp_instr_hreturn *i=
                NEW_PTN sp_instr_hreturn(sp->instructions(), pctx);

              if (!i || sp->add_instr(thd, i))
                MYSQL_YYABORT;
            }
            else
            {  
              sp_instr_hreturn *i=
                NEW_PTN sp_instr_hreturn(sp->instructions(), pctx);

              if (i == nullptr ||
                  sp->add_instr(thd, i) ||
                  sp->m_parser_data.add_backpatch_entry(i, pctx->last_label()))
                MYSQL_YYABORT;
            }

            sp->m_parser_data.do_backpatch(hlab, sp->instructions());

            lex->set_sp_current_parsing_ctx(pctx->pop_context());

            $$.vars= $$.conds= $$.curs= 0;
            $$.hndlrs= 1;
          }
|DECLARE_SYM ident CURSOR_SYM FOR_SYM {             
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
            sp->m_parser_data.set_current_stmt_start_ptr(@4.raw.end);
          }select_stmt {             
            MAKE_CMD($6);

            THD *thd= YYTHD;
            LEX *cursor_lex= Lex;
            sp_head *sp= cursor_lex->sphead;

            assert(cursor_lex->sql_command == SQLCOM_SELECT);

            if (cursor_lex->result)
            {
              my_error(ER_SP_BAD_CURSOR_SELECT, MYF(0));
              MYSQL_YYABORT;
            }

            cursor_lex->m_sql_cmd->set_as_part_of_sp();
            cursor_lex->sp_lex_in_use= true;

            if (sp->restore_lex(thd))
              MYSQL_YYABORT;

            LEX *lex= Lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            uint offp;

            if (pctx->find_cursor($2, &offp, true))
            {
              my_error(ER_SP_DUP_CURS, MYF(0), $2.str);
              delete cursor_lex;
              MYSQL_YYABORT;
            }

            LEX_CSTRING cursor_query= EMPTY_CSTR;

            if (cursor_lex->is_metadata_used())
            {
              cursor_query=
                make_string(thd,
                            sp->m_parser_data.get_current_stmt_start_ptr(),
                            @6.raw.end);

              if (!cursor_query.str)
                MYSQL_YYABORT;
            }

            sp_instr_cpush *i=
              NEW_PTN sp_instr_cpush(sp->instructions(), pctx,
                                     cursor_lex, cursor_query,
                                     pctx->current_cursor_count());

            if (i == nullptr ||
                sp->add_instr(thd, i) ||
                pctx->add_cursor($2))
            {
              MYSQL_YYABORT;
            }

            $$.vars= $$.conds= $$.hndlrs= 0;
            $$.curs= 1;
          }
;

sp_handler_type:
EXIT_SYM { $$= sp_handler::EXIT; }
|CONTINUE_SYM { $$= sp_handler::CONTINUE; }
;

sp_hcond_list:
sp_hcond_element { $$= 1; }
|sp_hcond_list ',' sp_hcond_element { $$+= 1; }
;

sp_hcond_element:
sp_hcond {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_pcontext *parent_pctx= pctx->parent_context();

            if (parent_pctx->check_duplicate_handler($1))
            {
              my_error(ER_SP_DUP_HANDLER, MYF(0));
              MYSQL_YYABORT;
            }
            else
            {
              sp_instr_hpush_jump *i=
                (sp_instr_hpush_jump *)sp->last_instruction();

              i->add_condition($1);
            }
          }
;

sp_cond:
ulong_num { 
            if ($1 == 0)
            {
              my_error(ER_WRONG_VALUE, MYF(0), "CONDITION", "0");
              MYSQL_YYABORT;
            }
            $$= NEW_PTN sp_condition_value($1);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|sqlstate 
;

sqlstate:
SQLSTATE_SYM opt_value TEXT_STRING_literal { 

            
            if (!is_sqlstate_valid(&$3) || is_sqlstate_completion($3.str))
            {
              my_error(ER_SP_BAD_SQLSTATE, MYF(0), $3.str);
              MYSQL_YYABORT;
            }
            $$= NEW_PTN sp_condition_value($3.str);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

opt_value:
%empty {}
|VALUE_SYM {}
;

sp_hcond:
sp_cond {
            $$= $1;
          }
|ident {
            LEX *lex= Lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            $$= pctx->find_condition($1, false);

            if ($$ == nullptr)
            {
              my_error(ER_SP_COND_MISMATCH, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
          }
|SQLWARNING_SYM {
            $$= NEW_PTN sp_condition_value(sp_condition_value::WARNING);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|not FOUND_SYM {
            $$= NEW_PTN sp_condition_value(sp_condition_value::NOT_FOUND);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|SQLEXCEPTION_SYM {
            $$= NEW_PTN sp_condition_value(sp_condition_value::EXCEPTION);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

signal_stmt:
SIGNAL_SYM signal_value opt_set_signal_information {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            lex->sql_command= SQLCOM_SIGNAL;
            lex->m_sql_cmd= NEW_PTN Sql_cmd_signal($2, $3);
            if (lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
          }
;

signal_value:
ident {
            LEX *lex= Lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            if (!pctx)
            {
              
              my_error(ER_SP_COND_MISMATCH, MYF(0), $1.str);
              MYSQL_YYABORT;
            }

            sp_condition_value *cond= pctx->find_condition($1, false);

            if (!cond)
            {
              my_error(ER_SP_COND_MISMATCH, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
            if (cond->type != sp_condition_value::SQLSTATE)
            {
              my_error(ER_SIGNAL_BAD_CONDITION_TYPE, MYF(0));
              MYSQL_YYABORT;
            }
            $$= cond;
          }
|sqlstate { $$= $1; }
;

opt_signal_value:
%empty { $$= nullptr; }
|signal_value { $$= $1; }
;

opt_set_signal_information:
%empty { $$= NEW_PTN Set_signal_information(); }
|SET_SYM signal_information_item_list { $$= $2; }
;

signal_information_item_list:
signal_condition_information_item_name EQ signal_allowed_expr {
            $$= NEW_PTN Set_signal_information();
            if ($$->set_item($1, $3))
              MYSQL_YYABORT;
          }
|signal_information_item_list ',' signal_condition_information_item_name EQ signal_allowed_expr {
            $$= $1;
            if ($$->set_item($3, $5))
              MYSQL_YYABORT;
          }
;

signal_allowed_expr:
literal_or_null { ITEMIZE($1, &$$); }
|rvalue_system_or_user_variable { ITEMIZE($1, &$$); }
|simple_ident { ITEMIZE($1, &$$); }
;

signal_condition_information_item_name:
CLASS_ORIGIN_SYM { $$= CIN_CLASS_ORIGIN; }
|SUBCLASS_ORIGIN_SYM { $$= CIN_SUBCLASS_ORIGIN; }
|CONSTRAINT_CATALOG_SYM { $$= CIN_CONSTRAINT_CATALOG; }
|CONSTRAINT_SCHEMA_SYM { $$= CIN_CONSTRAINT_SCHEMA; }
|CONSTRAINT_NAME_SYM { $$= CIN_CONSTRAINT_NAME; }
|CATALOG_NAME_SYM { $$= CIN_CATALOG_NAME; }
|SCHEMA_NAME_SYM { $$= CIN_SCHEMA_NAME; }
|TABLE_NAME_SYM { $$= CIN_TABLE_NAME; }
|COLUMN_NAME_SYM { $$= CIN_COLUMN_NAME; }
|CURSOR_NAME_SYM { $$= CIN_CURSOR_NAME; }
|MESSAGE_TEXT_SYM { $$= CIN_MESSAGE_TEXT; }
|MYSQL_ERRNO_SYM { $$= CIN_MYSQL_ERRNO; }
;

resignal_stmt:
RESIGNAL_SYM opt_signal_value opt_set_signal_information {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            lex->sql_command= SQLCOM_RESIGNAL;
            lex->keep_diagnostics= DA_KEEP_DIAGNOSTICS; 
            lex->m_sql_cmd= NEW_PTN Sql_cmd_resignal($2, $3);
            if (lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
          }
;

get_diagnostics:
GET_SYM which_area DIAGNOSTICS_SYM diagnostics_information {
            Diagnostics_information *info= $4;

            info->set_which_da($2);

            Lex->keep_diagnostics= DA_KEEP_DIAGNOSTICS; 
            Lex->sql_command= SQLCOM_GET_DIAGNOSTICS;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_get_diagnostics(info);

            if (Lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
          }
;

which_area:
%empty { $$= Diagnostics_information::CURRENT_AREA; }
|CURRENT_SYM { $$= Diagnostics_information::CURRENT_AREA; }
|STACKED_SYM { $$= Diagnostics_information::STACKED_AREA; }
;

diagnostics_information:
statement_information {
            $$= NEW_PTN Statement_information($1);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|CONDITION_SYM condition_number condition_information {
            $$= NEW_PTN Condition_information($2, $3);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

statement_information:
statement_information_item {
            $$= NEW_PTN List<Statement_information_item>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|statement_information ',' statement_information_item {
            if ($1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
          }
;

statement_information_item:
simple_target_specification EQ statement_information_item_name {
            $$= NEW_PTN Statement_information_item($3, $1);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }

simple_target_specification:
ident {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            

            if (!sp)
            {
              my_error(ER_SP_UNDECLARED_VAR, MYF(0), $1.str);
              MYSQL_YYABORT;
            }

            $$=
              create_item_for_sp_var(
                thd, to_lex_cstring($1), nullptr,
                sp->m_parser_data.get_current_stmt_start_ptr(),
                @1.raw.start,
                @1.raw.end);

            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|'@' ident_or_text {
            $$= NEW_PTN Item_func_get_user_var(@$, $2);
            ITEMIZE($$, &$$);
          }
;

statement_information_item_name:
NUMBER_SYM { $$= Statement_information_item::NUMBER; }
|ROW_COUNT_SYM { $$= Statement_information_item::ROW_COUNT; }
;

condition_number:
signal_allowed_expr { $$= $1; }
;

condition_information:
condition_information_item {
            $$= NEW_PTN List<Condition_information_item>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|condition_information ',' condition_information_item {
            if ($1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
          }
;

condition_information_item:
simple_target_specification EQ condition_information_item_name {
            $$= NEW_PTN Condition_information_item($3, $1);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }

condition_information_item_name:
CLASS_ORIGIN_SYM { $$= Condition_information_item::CLASS_ORIGIN; }
|SUBCLASS_ORIGIN_SYM { $$= Condition_information_item::SUBCLASS_ORIGIN; }
|CONSTRAINT_CATALOG_SYM { $$= Condition_information_item::CONSTRAINT_CATALOG; }
|CONSTRAINT_SCHEMA_SYM { $$= Condition_information_item::CONSTRAINT_SCHEMA; }
|CONSTRAINT_NAME_SYM { $$= Condition_information_item::CONSTRAINT_NAME; }
|CATALOG_NAME_SYM { $$= Condition_information_item::CATALOG_NAME; }
|SCHEMA_NAME_SYM { $$= Condition_information_item::SCHEMA_NAME; }
|TABLE_NAME_SYM { $$= Condition_information_item::TABLE_NAME; }
|COLUMN_NAME_SYM { $$= Condition_information_item::COLUMN_NAME; }
|CURSOR_NAME_SYM { $$= Condition_information_item::CURSOR_NAME; }
|MESSAGE_TEXT_SYM { $$= Condition_information_item::MESSAGE_TEXT; }
|MYSQL_ERRNO_SYM { $$= Condition_information_item::MYSQL_ERRNO; }
|RETURNED_SQLSTATE_SYM { $$= Condition_information_item::RETURNED_SQLSTATE; }
;

sp_decl_idents:
ident {
            

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            if (pctx->find_variable($1.str, $1.length, true))
            {
              my_error(ER_SP_DUP_VAR, MYF(0), $1.str);
              MYSQL_YYABORT;
            }

            pctx->add_variable(thd,
                               $1,
                               MYSQL_TYPE_DECIMAL,
                               sp_variable::MODE_IN);
            $$= 1;
          }
|sp_decl_idents ',' ident {
            

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            if (pctx->find_variable($3.str, $3.length, true))
            {
              my_error(ER_SP_DUP_VAR, MYF(0), $3.str);
              MYSQL_YYABORT;
            }

            pctx->add_variable(thd,
                               $3,
                               MYSQL_TYPE_DECIMAL,
                               sp_variable::MODE_IN);
            $$= $1 + 1;
          }
;

sp_opt_default:
%empty {
            $$.expr_start= nullptr;
            $$.expr = nullptr;
          }
|DEFAULT_SYM expr {
            $$.expr_start= @1.raw.end;
            $$.expr= $2;
          }
;

sp_proc_stmt:
sp_proc_stmt_statement 
|sp_proc_stmt_return 
|sp_proc_stmt_if 
|case_stmt_specification 
|sp_labeled_block 
|sp_unlabeled_block 
|sp_labeled_control 
|sp_proc_stmt_unlabeled 
|sp_proc_stmt_leave 
|sp_proc_stmt_iterate 
|sp_proc_stmt_open 
|sp_proc_stmt_fetch 
|sp_proc_stmt_close 
;

sp_proc_stmt_if:
IF { Lex->sphead->m_parser_data.new_cont_backpatch(); }sp_if END IF {
            sp_head *sp= Lex->sphead;

            sp->m_parser_data.do_cont_backpatch(sp->instructions());
          }
;

sp_proc_stmt_statement:
{
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
            sp->m_parser_data.set_current_stmt_start_ptr(yylloc.raw.start);
          }simple_statement {
            if ($2 != nullptr)
              MAKE_CMD($2);

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->m_flags|= sp_get_flags_for_command(lex);

            
            if (lex->m_sql_cmd != nullptr)
              lex->m_sql_cmd->set_as_part_of_sp();

            
            assert((lex->sql_command != SQLCOM_SET_OPTION &&
                         lex->sql_command != SQLCOM_SET_PASSWORD) ||
                        lex->var_list.is_empty());
            if (lex->sql_command != SQLCOM_SET_OPTION &&
                lex->sql_command != SQLCOM_SET_PASSWORD)
            {
              

              LEX_CSTRING query=
                make_string(thd,
                            sp->m_parser_data.get_current_stmt_start_ptr(),
                            @2.raw.end);

              if (!query.str)
                MYSQL_YYABORT;

              

              sp_instr_stmt *i=
                NEW_PTN sp_instr_stmt(sp->instructions(), lex, query);

              if (!i || sp->add_instr(thd, i))
                MYSQL_YYABORT;
            }

            if (sp->restore_lex(thd))
              MYSQL_YYABORT;
          }
;

sp_proc_stmt_return:
RETURN_SYM {             
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
          }expr {             
            ITEMIZE($3, &$3);

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            

            LEX_CSTRING expr_query= EMPTY_CSTR;

            const char *expr_start_ptr= @1.raw.end;

            if (lex->is_metadata_used())
            {
              expr_query= make_string(thd, expr_start_ptr, @3.raw.end);
              if (!expr_query.str)
                MYSQL_YYABORT;
            }

            

            if (sp->m_type != enum_sp_type::FUNCTION)
            {
              my_error(ER_SP_BADRETURN, MYF(0));
              MYSQL_YYABORT;
            }

            

            sp->m_flags|= sp_head::HAS_RETURN;

            

            sp_instr_freturn *i=
              NEW_PTN sp_instr_freturn(sp->instructions(), lex, $3, expr_query,
                                       sp->m_return_field_def.sql_type);

            if (i == nullptr ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }
          }
;

sp_proc_stmt_unlabeled:
{ 
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            pctx->push_label(thd,
                             EMPTY_CSTR,
                             sp->instructions());
          }sp_unlabeled_control {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp->m_parser_data.do_backpatch(pctx->pop_label(),
                                           sp->instructions());
          }
;

sp_proc_stmt_leave:
LEAVE_SYM label_ident {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp = lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *lab= pctx->find_label($2);

            if (! lab)
            {
              my_error(ER_SP_LILABEL_MISMATCH, MYF(0), "LEAVE", $2.str);
              MYSQL_YYABORT;
            }

            uint ip= sp->instructions();

            
            bool exclusive= (lab->type == sp_label::BEGIN);

            size_t n= pctx->diff_handlers(lab->ctx, exclusive);

            if (n)
            {
              sp_instr_hpop *hpop= NEW_PTN sp_instr_hpop(ip++, pctx);

              if (!hpop || sp->add_instr(thd, hpop))
                MYSQL_YYABORT;
            }

            n= pctx->diff_cursors(lab->ctx, exclusive);

            if (n)
            {
              sp_instr_cpop *cpop= NEW_PTN sp_instr_cpop(ip++, pctx, n);

              if (!cpop || sp->add_instr(thd, cpop))
                MYSQL_YYABORT;
            }

            sp_instr_jump *i= NEW_PTN sp_instr_jump(ip, pctx);

            if (!i ||
                
                sp->m_parser_data.add_backpatch_entry(i, lab) ||
                sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
;

sp_proc_stmt_iterate:
ITERATE_SYM label_ident {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *lab= pctx->find_label($2);

            if (! lab || lab->type != sp_label::ITERATION)
            {
              my_error(ER_SP_LILABEL_MISMATCH, MYF(0), "ITERATE", $2.str);
              MYSQL_YYABORT;
            }

            uint ip= sp->instructions();

            
            size_t n= pctx->diff_handlers(lab->ctx, false);

            if (n)
            {
              sp_instr_hpop *hpop= NEW_PTN sp_instr_hpop(ip++, pctx);

              if (!hpop || sp->add_instr(thd, hpop))
                MYSQL_YYABORT;
            }

            
            n= pctx->diff_cursors(lab->ctx, false);

            if (n)
            {
              sp_instr_cpop *cpop= NEW_PTN sp_instr_cpop(ip++, pctx, n);

              if (!cpop || sp->add_instr(thd, cpop))
                MYSQL_YYABORT;
            }

            
            sp_instr_jump *i= NEW_PTN sp_instr_jump(ip, pctx, lab->ip);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
;

sp_proc_stmt_open:
OPEN_SYM ident {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            uint offset;

            if (! pctx->find_cursor($2, &offset, false))
            {
              my_error(ER_SP_CURSOR_MISMATCH, MYF(0), $2.str);
              MYSQL_YYABORT;
            }

            sp_instr_copen *i= NEW_PTN sp_instr_copen(sp->instructions(), pctx,
                                                      offset);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
;

sp_proc_stmt_fetch:
FETCH_SYM sp_opt_fetch_noise ident INTO {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            uint offset;

            if (! pctx->find_cursor($3, &offset, false))
            {
              my_error(ER_SP_CURSOR_MISMATCH, MYF(0), $3.str);
              MYSQL_YYABORT;
            }

            sp_instr_cfetch *i= NEW_PTN sp_instr_cfetch(sp->instructions(),
                                                        pctx, offset);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }sp_fetch_list {}
;

sp_proc_stmt_close:
CLOSE_SYM ident {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            uint offset;

            if (! pctx->find_cursor($2, &offset, false))
            {
              my_error(ER_SP_CURSOR_MISMATCH, MYF(0), $2.str);
              MYSQL_YYABORT;
            }

            sp_instr_cclose *i=
              NEW_PTN sp_instr_cclose(sp->instructions(), pctx, offset);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
;

sp_opt_fetch_noise:
%empty 
|NEXT_SYM FROM 
|FROM 
;

sp_fetch_list:
ident {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_variable *spv;

            if (!pctx || !(spv= pctx->find_variable($1.str, $1.length, false)))
            {
              my_error(ER_SP_UNDECLARED_VAR, MYF(0), $1.str);
              MYSQL_YYABORT;
            }

            
            sp_instr_cfetch *i= (sp_instr_cfetch *)sp->last_instruction();

            i->add_to_varlist(spv);
          }
|sp_fetch_list ',' ident {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_variable *spv;

            if (!pctx || !(spv= pctx->find_variable($3.str, $3.length, false)))
            {
              my_error(ER_SP_UNDECLARED_VAR, MYF(0), $3.str);
              MYSQL_YYABORT;
            }

            
            sp_instr_cfetch *i= (sp_instr_cfetch *)sp->last_instruction();

            i->add_to_varlist(spv);
          }
;

sp_if:
{                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
          }expr {                     
            ITEMIZE($2, &$2);

            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            

            LEX_CSTRING expr_query= EMPTY_CSTR;
            const char *expr_start_ptr= @0.raw.end;

            if (lex->is_metadata_used())
            {
              expr_query= make_string(thd, expr_start_ptr, @2.raw.end);
              if (!expr_query.str)
                MYSQL_YYABORT;
            }

            sp_instr_jump_if_not *i =
              NEW_PTN sp_instr_jump_if_not(sp->instructions(), lex,
                                           $2, expr_query);

            

            if (i == nullptr ||
                sp->m_parser_data.add_backpatch_entry(
                  i, pctx->push_label(thd, EMPTY_CSTR, 0)) ||
                sp->m_parser_data.add_cont_backpatch_entry(i) ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }
          }THEN_SYM sp_proc_stmts1 {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp_instr_jump *i = NEW_PTN sp_instr_jump(sp->instructions(), pctx);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;

            sp->m_parser_data.do_backpatch(pctx->pop_label(),
                                           sp->instructions());

            sp->m_parser_data.add_backpatch_entry(
              i, pctx->push_label(thd, EMPTY_CSTR, 0));
          }sp_elseifs {                     
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp->m_parser_data.do_backpatch(pctx->pop_label(),
                                           sp->instructions());
          }
;

sp_elseifs:
%empty 
|ELSEIF_SYM sp_if 
|ELSE sp_proc_stmts1 
;

case_stmt_specification:
simple_case_stmt 
|searched_case_stmt 
;

simple_case_stmt:
CASE_SYM {                             
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            case_stmt_action_case(thd);

            sp->reset_lex(thd); 
          }expr {                             
            ITEMIZE($3, &$3);

            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;

            

            LEX_CSTRING case_expr_query= EMPTY_CSTR;
            const char *expr_start_ptr= @1.raw.end;

            if (lex->is_metadata_used())
            {
              case_expr_query= make_string(thd, expr_start_ptr, @3.raw.end);
              if (!case_expr_query.str)
                MYSQL_YYABORT;
            }

            

            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            int case_expr_id= pctx->push_case_expr_id();

            if (case_expr_id < 0)
              MYSQL_YYABORT;

            

            sp_instr_set_case_expr *i=
              NEW_PTN sp_instr_set_case_expr(sp->instructions(), lex,
                                             case_expr_id, $3, case_expr_query);

            if (i == nullptr ||
                sp->m_parser_data.add_cont_backpatch_entry(i) ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }
          }simple_when_clause_list else_clause_opt END CASE_SYM {                             
            case_stmt_action_end_case(Lex, true);
          }
;

searched_case_stmt:
CASE_SYM {
            case_stmt_action_case(YYTHD);
          }searched_when_clause_list else_clause_opt END CASE_SYM {
            case_stmt_action_end_case(Lex, false);
          }
;

simple_when_clause_list:
simple_when_clause 
|simple_when_clause_list simple_when_clause 
;

searched_when_clause_list:
searched_when_clause 
|searched_when_clause_list searched_when_clause 
;

simple_when_clause:
WHEN_SYM {                             
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
          }expr {                             
            

            ITEMIZE($3, &$3);

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            

            LEX_CSTRING when_expr_query= EMPTY_CSTR;
            const char *expr_start_ptr= @1.raw.end;

            if (lex->is_metadata_used())
            {
              when_expr_query= make_string(thd, expr_start_ptr, @3.raw.end);
              if (!when_expr_query.str)
                MYSQL_YYABORT;
            }

            

            sp_instr_jump_case_when *i =
              NEW_PTN sp_instr_jump_case_when(sp->instructions(), lex,
                                              pctx->get_current_case_expr_id(),
                                              $3, when_expr_query);

            if (i == nullptr ||
                i->on_after_expr_parsing(thd) ||
                sp->m_parser_data.add_backpatch_entry(
                  i, pctx->push_label(thd, EMPTY_CSTR, 0)) ||
                sp->m_parser_data.add_cont_backpatch_entry(i) ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }
          }THEN_SYM sp_proc_stmts1 {                             
            if (case_stmt_action_then(YYTHD, Lex))
              MYSQL_YYABORT;
          }
;

searched_when_clause:
WHEN_SYM {                             
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
          }expr {                             
            ITEMIZE($3, &$3);

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            

            LEX_CSTRING when_query= EMPTY_CSTR;
            const char *expr_start_ptr= @1.raw.end;

            if (lex->is_metadata_used())
            {
              when_query= make_string(thd, expr_start_ptr, @3.raw.end);
              if (!when_query.str)
                MYSQL_YYABORT;
            }

            

            sp_instr_jump_if_not *i=
              NEW_PTN sp_instr_jump_if_not(sp->instructions(), lex, $3,
                                           when_query);

            if (i == nullptr ||
                sp->m_parser_data.add_backpatch_entry(
                  i, pctx->push_label(thd, EMPTY_CSTR, 0)) ||
                sp->m_parser_data.add_cont_backpatch_entry(i) ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }
          }THEN_SYM sp_proc_stmts1 {                             
            if (case_stmt_action_then(YYTHD, Lex))
              MYSQL_YYABORT;
          }
;

else_clause_opt:
%empty {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp_instr_error *i=
              NEW_PTN
                sp_instr_error(sp->instructions(), pctx, ER_SP_CASE_NOT_FOUND);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
|ELSE sp_proc_stmts1 
;

sp_labeled_control:
label_ident ':' {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *lab= pctx->find_label($1);

            if (lab)
            {
              my_error(ER_SP_LABEL_REDEFINE, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
            else
            {
              lab= pctx->push_label(YYTHD, $1, sp->instructions());
              lab->type= sp_label::ITERATION;
            }
          }sp_unlabeled_control sp_opt_label {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *lab= pctx->pop_label();

            if ($5.str)
            {
              if (my_strcasecmp(system_charset_info, $5.str, lab->name.str) != 0)
              {
                my_error(ER_SP_LABEL_MISMATCH, MYF(0), $5.str);
                MYSQL_YYABORT;
              }
            }
            sp->m_parser_data.do_backpatch(lab, sp->instructions());
          }
;

sp_opt_label:
%empty { $$= NULL_CSTR; }
|label_ident { $$= $1; }
;

sp_labeled_block:
label_ident ':' {
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *lab= pctx->find_label($1);

            if (lab)
            {
              my_error(ER_SP_LABEL_REDEFINE, MYF(0), $1.str);
              MYSQL_YYABORT;
            }

            lab= pctx->push_label(YYTHD, $1, sp->instructions());
            lab->type= sp_label::BEGIN;
          }sp_block_content sp_opt_label {
            LEX *lex= Lex;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            sp_label *lab= pctx->pop_label();

            if ($5.str)
            {
              if (my_strcasecmp(system_charset_info, $5.str, lab->name.str) != 0)
              {
                my_error(ER_SP_LABEL_MISMATCH, MYF(0), $5.str);
                MYSQL_YYABORT;
              }
            }
          }
;

sp_unlabeled_block:
{ 
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp_label *lab=
              pctx->push_label(YYTHD, EMPTY_CSTR, sp->instructions());

            lab->type= sp_label::BEGIN;
          }sp_block_content {
            LEX *lex= Lex;
            lex->get_sp_current_parsing_ctx()->pop_label();
          }
;

sp_block_content:
BEGIN_SYM { 
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_pcontext *parent_pctx= lex->get_sp_current_parsing_ctx();

            sp_pcontext *child_pctx=
              parent_pctx->push_context(thd, sp_pcontext::REGULAR_SCOPE);

            lex->set_sp_current_parsing_ctx(child_pctx);
          }sp_decls sp_proc_stmts END {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            
            sp->m_parser_data.do_backpatch(pctx->last_label(),
                                           sp->instructions());

            if ($3.hndlrs)
            {
              sp_instr *i= NEW_PTN sp_instr_hpop(sp->instructions(), pctx);

              if (!i || sp->add_instr(thd, i))
                MYSQL_YYABORT;
            }

            if ($3.curs)
            {
              sp_instr *i= NEW_PTN sp_instr_cpop(sp->instructions(), pctx,
                                                 $3.curs);

              if (!i || sp->add_instr(thd, i))
                MYSQL_YYABORT;
            }

            lex->set_sp_current_parsing_ctx(pctx->pop_context());
          }
;

sp_unlabeled_control:
LOOP_SYM sp_proc_stmts1 END LOOP_SYM {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp_instr_jump *i= NEW_PTN sp_instr_jump(sp->instructions(), pctx,
                                                    pctx->last_label()->ip);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
|WHILE_SYM {                             
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
          }expr {                             
            ITEMIZE($3, &$3);

            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            

            LEX_CSTRING expr_query= EMPTY_CSTR;
            const char *expr_start_ptr= @1.raw.end;

            if (lex->is_metadata_used())
            {
              expr_query= make_string(thd, expr_start_ptr, @3.raw.end);
              if (!expr_query.str)
                MYSQL_YYABORT;
            }

            

            sp_instr_jump_if_not *i=
              NEW_PTN
                sp_instr_jump_if_not(sp->instructions(), lex, $3, expr_query);

            if (i == nullptr ||
                
                sp->m_parser_data.add_backpatch_entry(i, pctx->last_label()) ||
                sp->m_parser_data.new_cont_backpatch() ||
                sp->m_parser_data.add_cont_backpatch_entry(i) ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }
          }DO_SYM sp_proc_stmts1 END WHILE_SYM {                             
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp_instr_jump *i= NEW_PTN sp_instr_jump(sp->instructions(), pctx,
                                                    pctx->last_label()->ip);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;

            sp->m_parser_data.do_cont_backpatch(sp->instructions());
          }
|REPEAT_SYM sp_proc_stmts1 UNTIL_SYM {                             
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
          }expr {                             
            ITEMIZE($5, &$5);

            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();
            uint ip= sp->instructions();

            

            LEX_CSTRING expr_query= EMPTY_CSTR;
            const char *expr_start_ptr= @3.raw.end;

            if (lex->is_metadata_used())
            {
              expr_query= make_string(thd, expr_start_ptr, @5.raw.end);
              if (!expr_query.str)
                MYSQL_YYABORT;
            }

            

            sp_instr_jump_if_not *i=
              NEW_PTN sp_instr_jump_if_not(ip, lex, $5, expr_query,
                                           pctx->last_label()->ip);

            if (i == nullptr ||
                sp->add_instr(thd, i) ||
                sp->restore_lex(thd))
            {
              MYSQL_YYABORT;
            }

            
            i->set_cont_dest(ip + 1);
          }END REPEAT_SYM 
;

trg_action_time:
BEFORE_SYM { $$= TRG_ACTION_BEFORE; }
|AFTER_SYM { $$= TRG_ACTION_AFTER; }
;

trg_event:
INSERT_SYM { $$= TRG_EVENT_INSERT; }
|UPDATE_SYM { $$= TRG_EVENT_UPDATE; }
|DELETE_SYM { $$= TRG_EVENT_DELETE; }
;

opt_ts_datafile_name:
%empty { $$= { nullptr, 0}; }
|ADD ts_datafile {
        $$ = $2;
      }
;

opt_logfile_group_name:
%empty { $$= { nullptr, 0}; }
|USE_SYM LOGFILE_SYM GROUP_SYM ident {
            $$= $4;
          }
;

opt_tablespace_options:
%empty { $$= nullptr; }
|tablespace_option_list 
;

tablespace_option_list:
tablespace_option {
            $$= NEW_PTN Mem_root_array<PT_alter_tablespace_option_base*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;  
          }
|tablespace_option_list opt_comma tablespace_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;  
          }
;

tablespace_option:
ts_option_initial_size 
|ts_option_autoextend_size 
|ts_option_max_size 
|ts_option_extent_size 
|ts_option_nodegroup 
|ts_option_engine 
|ts_option_wait 
|ts_option_comment 
|ts_option_file_block_size 
|ts_option_encryption 
|ts_option_engine_attribute 
;

opt_alter_tablespace_options:
%empty { $$= nullptr; }
|alter_tablespace_option_list 
;

alter_tablespace_option_list:
alter_tablespace_option {
            $$= NEW_PTN Mem_root_array<PT_alter_tablespace_option_base*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;  
          }
|alter_tablespace_option_list opt_comma alter_tablespace_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;  
          }
;

alter_tablespace_option:
ts_option_initial_size 
|ts_option_autoextend_size 
|ts_option_max_size 
|ts_option_engine 
|ts_option_wait 
|ts_option_encryption 
|ts_option_engine_attribute 
;

opt_undo_tablespace_options:
%empty { $$= nullptr; }
|undo_tablespace_option_list 
;

undo_tablespace_option_list:
undo_tablespace_option {
            $$= NEW_PTN Mem_root_array<PT_alter_tablespace_option_base*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|undo_tablespace_option_list opt_comma undo_tablespace_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

undo_tablespace_option:
ts_option_engine 
;

opt_logfile_group_options:
%empty { $$= nullptr; }
|logfile_group_option_list 
;

logfile_group_option_list:
logfile_group_option {
            $$= NEW_PTN Mem_root_array<PT_alter_tablespace_option_base*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;  
          }
|logfile_group_option_list opt_comma logfile_group_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;  
          }
;

logfile_group_option:
ts_option_initial_size 
|ts_option_undo_buffer_size 
|ts_option_redo_buffer_size 
|ts_option_nodegroup 
|ts_option_engine 
|ts_option_wait 
|ts_option_comment 
;

opt_alter_logfile_group_options:
%empty { $$= nullptr; }
|alter_logfile_group_option_list 
;

alter_logfile_group_option_list:
alter_logfile_group_option {
            $$= NEW_PTN Mem_root_array<PT_alter_tablespace_option_base*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;  
          }
|alter_logfile_group_option_list opt_comma alter_logfile_group_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;  
          }
;

alter_logfile_group_option:
ts_option_initial_size 
|ts_option_engine 
|ts_option_wait 
;

ts_datafile:
DATAFILE_SYM TEXT_STRING_sys { $$= $2; }
;

undo_tablespace_state:
ACTIVE_SYM { $$= ALTER_UNDO_TABLESPACE_SET_ACTIVE; }
|INACTIVE_SYM { $$= ALTER_UNDO_TABLESPACE_SET_INACTIVE; }
;

lg_undofile:
UNDOFILE_SYM TEXT_STRING_sys { $$= $2; }
;

ts_option_initial_size:
INITIAL_SIZE_SYM opt_equal size_number {
            $$= NEW_PTN PT_alter_tablespace_option_initial_size(@$, $3);
          }
;

ts_option_autoextend_size:
option_autoextend_size {
            $$ = NEW_PTN PT_alter_tablespace_option_autoextend_size(@$, $1);
          }
;

option_autoextend_size:
AUTOEXTEND_SIZE_SYM opt_equal size_number { $$ = $3; }
;

ts_option_max_size:
MAX_SIZE_SYM opt_equal size_number {
            $$= NEW_PTN PT_alter_tablespace_option_max_size(@$, $3);
          }
;

ts_option_extent_size:
EXTENT_SIZE_SYM opt_equal size_number {
            $$= NEW_PTN PT_alter_tablespace_option_extent_size(@$, $3);
          }
;

ts_option_undo_buffer_size:
UNDO_BUFFER_SIZE_SYM opt_equal size_number {
            $$= NEW_PTN PT_alter_tablespace_option_undo_buffer_size(@$, $3);
          }
;

ts_option_redo_buffer_size:
REDO_BUFFER_SIZE_SYM opt_equal size_number {
            $$= NEW_PTN PT_alter_tablespace_option_redo_buffer_size(@$, $3);
          }
;

ts_option_nodegroup:
NODEGROUP_SYM opt_equal real_ulong_num {
            $$= NEW_PTN PT_alter_tablespace_option_nodegroup(@$, $3);
          }
;

ts_option_comment:
COMMENT_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_alter_tablespace_option_comment(@$, $3);
          }
;

ts_option_engine:
opt_storage ENGINE_SYM opt_equal ident_or_text {
            $$= NEW_PTN PT_alter_tablespace_option_engine(@$, to_lex_cstring($4));
          }
;

ts_option_file_block_size:
FILE_BLOCK_SIZE_SYM opt_equal size_number {
            $$= NEW_PTN PT_alter_tablespace_option_file_block_size(@$, $3);
          }
;

ts_option_wait:
WAIT_SYM {
            $$= NEW_PTN PT_alter_tablespace_option_wait_until_completed(@$, true);
          }
|NO_WAIT_SYM {
            $$= NEW_PTN PT_alter_tablespace_option_wait_until_completed(@$, false);
          }
;

ts_option_encryption:
ENCRYPTION_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_alter_tablespace_option_encryption(@$, $3);
          }
;

ts_option_engine_attribute:
ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_tablespace_engine_attribute(YYMEM_ROOT, $3);
          }
;

size_number:
real_ulonglong_num { $$= $1;}
|IDENT_sys {
            ulonglong number;
            uint text_shift_number= 0;
            longlong prefix_number;
            const char *start_ptr= $1.str;
            size_t str_len= $1.length;
            const char *end_ptr= start_ptr + str_len;
            int error;
            prefix_number= my_strtoll10(start_ptr, &end_ptr, &error);
            if ((start_ptr + str_len - 1) == end_ptr)
            {
              switch (end_ptr[0])
              {
                case 'g':
                case 'G':
                  text_shift_number+=10;
                  [[fallthrough]];
                case 'm':
                case 'M':
                  text_shift_number+=10;
                  [[fallthrough]];
                case 'k':
                case 'K':
                  text_shift_number+=10;
                  break;
                default:
                {
                  my_error(ER_WRONG_SIZE_NUMBER, MYF(0));
                  MYSQL_YYABORT;
                }
              }
              if (prefix_number >> 31)
              {
                my_error(ER_SIZE_OVERFLOW_ERROR, MYF(0));
                MYSQL_YYABORT;
              }
              number= prefix_number << text_shift_number;
            }
            else
            {
              my_error(ER_WRONG_SIZE_NUMBER, MYF(0));
              MYSQL_YYABORT;
            }
            $$= number;
          }
;

opt_create_table_options_etc:
create_table_options opt_create_partitioning_etc {
            $$= $2;
            $$.opt_create_table_options= $1;
          }
|opt_create_partitioning_etc 
;

opt_create_partitioning_etc:
partition_clause opt_duplicate_as_qe {
            $$= $2;
            $$.opt_partitioning= $1;
          }
|opt_duplicate_as_qe 
;

opt_duplicate_as_qe:
%empty {
            $$.opt_create_table_options= nullptr;
            $$.opt_partitioning= nullptr;
            $$.on_duplicate= On_duplicate::ERROR;
            $$.opt_query_expression= nullptr;
          }
|duplicate as_create_query_expression {
            $$.opt_create_table_options= nullptr;
            $$.opt_partitioning= nullptr;
            $$.on_duplicate= $1;
            $$.opt_query_expression= $2;
          }
|as_create_query_expression {
            $$.opt_create_table_options= nullptr;
            $$.opt_partitioning= nullptr;
            $$.on_duplicate= On_duplicate::ERROR;
            $$.opt_query_expression= $1;
          }
;

as_create_query_expression:
AS query_expression_with_opt_locking_clauses { $$ = $2; }
|query_expression_with_opt_locking_clauses { $$ = $1; }
;

partition_clause:
PARTITION_SYM BY part_type_def opt_num_parts opt_sub_part opt_part_defs {
            $$= NEW_PTN PT_partition(@$, $3, $4, $5, @6, $6);
          }
;

part_type_def:
opt_linear KEY_SYM opt_key_algo '(' opt_name_list ')' {
            $$= NEW_PTN PT_part_type_def_key(@$, $1, $3, $5);
          }
|opt_linear HASH_SYM '(' bit_expr ')' {
            $$= NEW_PTN PT_part_type_def_hash(@$, $1, @4, $4);
          }
|RANGE_SYM '(' bit_expr ')' {
            $$= NEW_PTN PT_part_type_def_range_expr(@$, @3, $3);
          }
|RANGE_SYM COLUMNS '(' name_list ')' {
            $$= NEW_PTN PT_part_type_def_range_columns(@$, $4);
          }
|LIST_SYM '(' bit_expr ')' {
            $$= NEW_PTN PT_part_type_def_list_expr(@$, @3, $3);
          }
|LIST_SYM COLUMNS '(' name_list ')' {
            $$= NEW_PTN PT_part_type_def_list_columns(@$, $4);
          }
;

opt_linear:
%empty { $$= false; }
|LINEAR_SYM { $$= true; }
;

opt_key_algo:
%empty { $$= enum_key_algorithm::KEY_ALGORITHM_NONE; }
|ALGORITHM_SYM EQ real_ulong_num {
            switch ($3) {
            case 1:
              $$= enum_key_algorithm::KEY_ALGORITHM_51;
              break;
            case 2:
              $$= enum_key_algorithm::KEY_ALGORITHM_55;
              break;
            default:
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
          }
;

opt_num_parts:
%empty { $$= 0; }
|PARTITIONS_SYM real_ulong_num {
            if ($2 == 0)
            {
              my_error(ER_NO_PARTS_ERROR, MYF(0), "partitions");
              MYSQL_YYABORT;
            }
            $$= $2;
          }
;

opt_sub_part:
%empty { $$= nullptr; }
|SUBPARTITION_SYM BY opt_linear HASH_SYM '(' bit_expr ')' opt_num_subparts {
            $$= NEW_PTN PT_sub_partition_by_hash(@$, $3, @6, $6, $8);
          }
|SUBPARTITION_SYM BY opt_linear KEY_SYM opt_key_algo '(' name_list ')' opt_num_subparts {
            $$= NEW_PTN PT_sub_partition_by_key(@$, $3, $5, $7, $9);
          }
;

opt_name_list:
%empty { $$= nullptr; }
|name_list 
;

name_list:
ident {
            $$= NEW_PTN List<char>;
            if ($$ == nullptr || $$->push_back($1.str))
              MYSQL_YYABORT;
          }
|name_list ',' ident {
            $$= $1;
            if ($$->push_back($3.str))
              MYSQL_YYABORT;
          }
;

opt_num_subparts:
%empty { $$= 0; }
|SUBPARTITIONS_SYM real_ulong_num {
            if ($2 == 0)
            {
              my_error(ER_NO_PARTS_ERROR, MYF(0), "subpartitions");
              MYSQL_YYABORT;
            }
            $$= $2;
          }
;

opt_part_defs:
%empty { $$= nullptr; }
|'(' part_def_list ')' { $$= $2; }
;

part_def_list:
part_definition {
            $$= NEW_PTN Mem_root_array<PT_part_definition*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|part_def_list ',' part_definition {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

part_definition:
PARTITION_SYM ident opt_part_values opt_part_options opt_sub_partition {
            $$= NEW_PTN PT_part_definition(@$, @0, $2, $3.type, $3.values, @3,
                                           $4, $5, @5);
          }
;

opt_part_values:
%empty {
            $$.type= partition_type::HASH;
          }
|VALUES LESS_SYM THAN_SYM part_func_max {
            $$.type= partition_type::RANGE;
            $$.values= $4;
          }
|VALUES IN_SYM part_values_in {
            $$.type= partition_type::LIST;
            $$.values= $3;
          }
;

part_func_max:
MAX_VALUE_SYM { $$= nullptr; }
|part_value_item_list_paren 
;

part_values_in:
part_value_item_list_paren {
            $$= NEW_PTN PT_part_values_in_item(@$, @1, $1);
          }
|'(' part_value_list ')' {
            $$= NEW_PTN PT_part_values_in_list(@$, @3, $2);
          }
;

part_value_list:
part_value_item_list_paren {
            $$= NEW_PTN
              Mem_root_array<PT_part_value_item_list_paren *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|part_value_list ',' part_value_item_list_paren {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

part_value_item_list_paren:
'(' {
            
          }part_value_item_list ')' {
            $$= NEW_PTN PT_part_value_item_list_paren(@$, $3, @4);
          }
;

part_value_item_list:
part_value_item {
            $$= NEW_PTN Mem_root_array<PT_part_value_item *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|part_value_item_list ',' part_value_item {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

part_value_item:
MAX_VALUE_SYM { $$= NEW_PTN PT_part_value_item_max(@$); }
|bit_expr { $$= NEW_PTN PT_part_value_item_expr(@$, $1); }
;

opt_sub_partition:
%empty { $$= nullptr; }
|'(' sub_part_list ')' { $$= $2; }
;

sub_part_list:
sub_part_definition {
            $$= NEW_PTN Mem_root_array<PT_subpartition *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|sub_part_list ',' sub_part_definition {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

sub_part_definition:
SUBPARTITION_SYM ident_or_text opt_part_options {
            $$= NEW_PTN PT_subpartition(@$, @1, $2.str, $3);
          }
;

opt_part_options:
%empty { $$= nullptr; }
|part_option_list 
;

part_option_list:
part_option_list part_option {
            $$= $1;
            if ($$->push_back($2))
              MYSQL_YYABORT; 
          }
|part_option {
            $$= NEW_PTN Mem_root_array<PT_partition_option *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
;

part_option:
TABLESPACE_SYM opt_equal ident { $$= NEW_PTN PT_partition_tablespace(@$, $3.str); }
|opt_storage ENGINE_SYM opt_equal ident_or_text { $$= NEW_PTN PT_partition_engine(@$, to_lex_cstring($4)); }
|NODEGROUP_SYM opt_equal real_ulong_num { $$= NEW_PTN PT_partition_nodegroup(@$, $3); }
|MAX_ROWS opt_equal real_ulonglong_num { $$= NEW_PTN PT_partition_max_rows(@$, $3); }
|MIN_ROWS opt_equal real_ulonglong_num { $$= NEW_PTN PT_partition_min_rows(@$, $3); }
|DATA_SYM DIRECTORY_SYM opt_equal TEXT_STRING_sys { $$= NEW_PTN PT_partition_data_directory(@$, $4.str); }
|INDEX_SYM DIRECTORY_SYM opt_equal TEXT_STRING_sys { $$= NEW_PTN PT_partition_index_directory(@$, $4.str); }
|COMMENT_SYM opt_equal TEXT_STRING_sys { $$= NEW_PTN PT_partition_comment(@$, $3.str); }
;

alter_database_options:
alter_database_option 
|alter_database_options alter_database_option 
;

alter_database_option:
create_database_option 
|READ_SYM ONLY_SYM opt_equal ternary_option {
            
            if ((Lex->create_info->used_fields &
                 HA_CREATE_USED_READ_ONLY) &&
                (Lex->create_info->schema_read_only !=
                    ($4 == Ternary_option::ON))) {
              my_error(ER_CONFLICTING_DECLARATIONS, MYF(0), "READ ONLY", "=0",
                  "READ ONLY", "=1");
              MYSQL_YYABORT;
            }
            Lex->create_info->schema_read_only = ($4 == Ternary_option::ON);
            Lex->create_info->used_fields |= HA_CREATE_USED_READ_ONLY;
          }
;

opt_create_database_options:
%empty {}
|create_database_options {}
;

create_database_options:
create_database_option {}
|create_database_options create_database_option {}
;

create_database_option:
default_collation {
            if (set_default_collation(Lex->create_info, $1))
              MYSQL_YYABORT;
          }
|default_charset {
            if (set_default_charset(Lex->create_info, $1))
              MYSQL_YYABORT;
          }
|default_encryption {
            
            if (my_strcasecmp(system_charset_info, $1.str, "Y") != 0 &&
                my_strcasecmp(system_charset_info, $1.str, "N") != 0) {
              my_error(ER_WRONG_VALUE, MYF(0), "argument (should be Y or N)", $1.str);
              MYSQL_YYABORT;
            }

            Lex->create_info->encrypt_type= $1;
            Lex->create_info->used_fields |= HA_CREATE_USED_DEFAULT_ENCRYPTION;
          }
;

opt_if_not_exists:
%empty { $$= false; }
|IF not EXISTS { $$= true; }
;

create_table_options_space_separated:
create_table_option {
            $$= NEW_PTN Mem_root_array<PT_ddl_table_option *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|create_table_options_space_separated create_table_option {
            $$= $1;
            if ($$->push_back($2))
              MYSQL_YYABORT; 
          }
;

create_table_options:
create_table_option {
            $$= NEW_PTN Mem_root_array<PT_create_table_option *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|create_table_options opt_comma create_table_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

opt_comma:
%empty 
|',' 
;

create_table_option:
ENGINE_SYM opt_equal ident_or_text {
            $$= NEW_PTN PT_create_table_engine_option(@$, to_lex_cstring($3));
          }
|SECONDARY_ENGINE_SYM opt_equal NULL_SYM {
            $$= NEW_PTN PT_create_table_secondary_engine_option(@$);
          }
|SECONDARY_ENGINE_SYM opt_equal ident_or_text {
            $$= NEW_PTN PT_create_table_secondary_engine_option(@$, to_lex_cstring($3));
          }
|MAX_ROWS opt_equal ulonglong_num {
            $$= NEW_PTN PT_create_max_rows_option(@$, $3);
          }
|MIN_ROWS opt_equal ulonglong_num {
            $$= NEW_PTN PT_create_min_rows_option(@$, $3);
          }
|AVG_ROW_LENGTH opt_equal ulonglong_num {
            
            
            
            if ($3 > std::numeric_limits<std::uint32_t>::max()) {
              YYTHD->syntax_error_at(@3,
              "The valid range for avg_row_length is [0,4294967295]. Error"
              );
              MYSQL_YYABORT;
            }
            $$= NEW_PTN PT_create_avg_row_length_option(@$, $3);
          }
|PASSWORD opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_password_option(@$, $3.str);
          }
|COMMENT_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_commen_option(@$, $3);
          }
|COMPRESSION_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_compress_option(@$, $3);
          }
|ENCRYPTION_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_encryption_option(@$, $3);
          }
|AUTO_INC opt_equal ulonglong_num {
            $$= NEW_PTN PT_create_auto_increment_option(@$, $3);
          }
|PACK_KEYS_SYM opt_equal ternary_option {
            $$= NEW_PTN PT_create_pack_keys_option(@$, $3);
          }
|STATS_AUTO_RECALC_SYM opt_equal ternary_option {
            $$= NEW_PTN PT_create_stats_auto_recalc_option(@$, $3);
          }
|STATS_PERSISTENT_SYM opt_equal ternary_option {
            $$= NEW_PTN PT_create_stats_persistent_option(@$, $3);
          }
|STATS_SAMPLE_PAGES_SYM opt_equal ulong_num {
            
            if ($3 == 0 || $3 > 0xffff)
            {
              YYTHD->syntax_error_at(@3,
              "The valid range for stats_sample_pages is [1, 65535]. Error");
              MYSQL_YYABORT;
            }
            $$= NEW_PTN PT_create_stats_stable_pages(@$, $3);
          }
|STATS_SAMPLE_PAGES_SYM opt_equal DEFAULT_SYM {
            $$= NEW_PTN PT_create_stats_stable_pages(@$);
          }
|CHECKSUM_SYM opt_equal ulong_num {
            $$= NEW_PTN PT_create_checksum_option(@$, $3);
          }
|TABLE_CHECKSUM_SYM opt_equal ulong_num {
            $$= NEW_PTN PT_create_checksum_option(@$, $3);
          }
|DELAY_KEY_WRITE_SYM opt_equal ulong_num {
            $$= NEW_PTN PT_create_delay_key_write_option(@$, $3);
          }
|ROW_FORMAT_SYM opt_equal row_types {
            $$= NEW_PTN PT_create_row_format_option(@$, $3);
          }
|UNION_SYM opt_equal '(' opt_table_list ')' {
            $$= NEW_PTN PT_create_union_option(@$, $4);
          }
|default_charset {
            $$= NEW_PTN PT_create_table_default_charset(@$, $1);
          }
|default_collation {
            $$= NEW_PTN PT_create_table_default_collation(@$, $1);
          }
|INSERT_METHOD opt_equal merge_insert_types {
            $$= NEW_PTN PT_create_insert_method_option(@$, $3);
          }
|DATA_SYM DIRECTORY_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_data_directory_option(@$, $4.str);
          }
|INDEX_SYM DIRECTORY_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_index_directory_option(@$, $4.str);
          }
|TABLESPACE_SYM opt_equal ident {
            $$= NEW_PTN PT_create_tablespace_option(@$, $3.str);
          }
|STORAGE_SYM DISK_SYM {
            $$= NEW_PTN PT_create_storage_option(@$, HA_SM_DISK);
          }
|STORAGE_SYM MEMORY_SYM {
            $$= NEW_PTN PT_create_storage_option(@$, HA_SM_MEMORY);
          }
|CONNECTION_SYM opt_equal TEXT_STRING_sys {
            $$= NEW_PTN PT_create_connection_option(@$, $3);
          }
|KEY_BLOCK_SIZE opt_equal ulonglong_num {
            
            
            
            if ($3 > std::numeric_limits<std::uint16_t>::max()) {
              YYTHD->syntax_error_at(@3,
              "The valid range for key_block_size is [0,65535]. Error");
              MYSQL_YYABORT;
            }

            $$= NEW_PTN
            PT_create_key_block_size_option(@$, static_cast<std::uint32_t>($3));
          }
|START_SYM TRANSACTION_SYM {
            $$= NEW_PTN PT_create_start_transaction_option(@$, true);
	  }
|ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_table_engine_attribute(YYMEM_ROOT, $3);
          }
|SECONDARY_ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_table_secondary_engine_attribute(YYMEM_ROOT, $3);
          }
|option_autoextend_size {
            $$ = NEW_PTN PT_create_ts_autoextend_size_option(@$, $1);
          }
;

ternary_option:
ulong_num {
            switch($1) {
            case 0:
                $$= Ternary_option::OFF;
                break;
            case 1:
                $$= Ternary_option::ON;
                break;
            default:
                YYTHD->syntax_error();
                MYSQL_YYABORT;
            }
          }
|DEFAULT_SYM { $$= Ternary_option::DEFAULT; }
;

default_charset:
opt_default character_set opt_equal charset_name { $$ = $4; }
;

default_collation:
opt_default COLLATE_SYM opt_equal collation_name { $$ = $4;}
;

default_encryption:
opt_default ENCRYPTION_SYM opt_equal TEXT_STRING_sys { $$ = $4;}
;

row_types:
DEFAULT_SYM { $$= ROW_TYPE_DEFAULT; }
|FIXED_SYM { $$= ROW_TYPE_FIXED; }
|DYNAMIC_SYM { $$= ROW_TYPE_DYNAMIC; }
|COMPRESSED_SYM { $$= ROW_TYPE_COMPRESSED; }
|REDUNDANT_SYM { $$= ROW_TYPE_REDUNDANT; }
|COMPACT_SYM { $$= ROW_TYPE_COMPACT; }
;

merge_insert_types:
NO_SYM { $$= MERGE_INSERT_DISABLED; }
|FIRST_SYM { $$= MERGE_INSERT_TO_FIRST; }
|LAST_SYM { $$= MERGE_INSERT_TO_LAST; }
;

udf_type:
STRING_SYM {$$ = (int) STRING_RESULT; }
|REAL_SYM {$$ = (int) REAL_RESULT; }
|DECIMAL_SYM {$$ = (int) DECIMAL_RESULT; }
|INT_SYM {$$ = (int) INT_RESULT; }
;

table_element_list:
table_element {
            $$= NEW_PTN Mem_root_array<PT_table_element *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|table_element_list ',' table_element {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

table_element:
column_def { $$= $1; }
|table_constraint_def { $$= $1; }
;

column_def:
ident field_def opt_references {
            $$= NEW_PTN PT_column_def(@$, $1, $2, $3);
          }
;

opt_references:
%empty { $$= nullptr; }
|references {
            
            $$= nullptr;
          }
;

table_constraint_def:
key_or_index opt_index_name_and_type '(' key_list_with_expression ')' opt_index_options {
            $$= NEW_PTN PT_inline_index_definition(@$, KEYTYPE_MULTIPLE,
                                                   $2.name, $2.type, $4, $6);
          }
|FULLTEXT_SYM opt_key_or_index opt_ident '(' key_list_with_expression ')' opt_fulltext_index_options {
            $$= NEW_PTN PT_inline_index_definition(@$, KEYTYPE_FULLTEXT, $3, nullptr,
                                                   $5, $7);
          }
|SPATIAL_SYM opt_key_or_index opt_ident '(' key_list_with_expression ')' opt_spatial_index_options {
            $$= NEW_PTN PT_inline_index_definition(@$, KEYTYPE_SPATIAL, $3, nullptr, $5, $7);
          }
|opt_constraint_name constraint_key_type opt_index_name_and_type '(' key_list_with_expression ')' opt_index_options {
            
            LEX_STRING name= $3.name.str != nullptr ? $3.name : $1;
            $$= NEW_PTN PT_inline_index_definition(@$, $2, name, $3.type, $5, $7);
          }
|opt_constraint_name FOREIGN KEY_SYM opt_ident '(' key_list ')' references {
            $$= NEW_PTN PT_foreign_key_definition(@$, $1, $4, $6, $8.table_name,
                                                  $8.reference_list,
                                                  $8.fk_match_option,
                                                  $8.fk_update_opt,
                                                  $8.fk_delete_opt);
          }
|opt_constraint_name check_constraint opt_constraint_enforcement {
            $$= NEW_PTN PT_check_constraint(@$, $1, $2, $3);
            if ($$ == nullptr) MYSQL_YYABORT; 
          }
;

check_constraint:
CHECK_SYM '(' expr ')' { $$= $3; }
;

opt_constraint_name:
%empty { $$= NULL_STR; }
|CONSTRAINT opt_ident { $$= $2; }
;

opt_not:
%empty { $$= false; }
|NOT_SYM { $$= true; }
;

opt_constraint_enforcement:
%empty { $$= true; }
|constraint_enforcement { $$= $1; }
;

constraint_enforcement:
opt_not ENFORCED_SYM { $$= !($1); }
;

field_def:
type opt_column_attribute_list {
            $$= NEW_PTN PT_field_def(@$, $1, $2);
          }
|type opt_collate opt_generated_always AS '(' expr ')' opt_stored_attribute opt_column_attribute_list {
            auto *opt_attrs= $9;
            if ($2 != nullptr)
            {
              if (opt_attrs == nullptr)
              {
                opt_attrs= NEW_PTN
                  Mem_root_array<PT_column_attr_base *>(YYMEM_ROOT);
              }
              auto *collation= NEW_PTN PT_collate_column_attr(@2, $2);
              if (opt_attrs == nullptr || collation == nullptr ||
                  opt_attrs->push_back(collation))
                MYSQL_YYABORT; 
            }
            $$= NEW_PTN PT_generated_field_def(@$, $1, $6, $8, opt_attrs);
          }
;

opt_generated_always:
%empty 
|GENERATED ALWAYS_SYM 
;

opt_stored_attribute:
%empty { $$= Virtual_or_stored::VIRTUAL; }
|VIRTUAL_SYM { $$= Virtual_or_stored::VIRTUAL; }
|STORED_SYM { $$= Virtual_or_stored::STORED; }
;

type:
int_type opt_field_length field_options {
            $$= NEW_PTN PT_numeric_type(@$, YYTHD, $1, $2, $3);
          }
|real_type opt_precision field_options {
            $$= NEW_PTN PT_numeric_type(@$, YYTHD, $1, $2.length, $2.dec, $3);
          }
|numeric_type float_options field_options {
            $$= NEW_PTN PT_numeric_type(@$, YYTHD, $1, $2.length, $2.dec, $3);
          }
|BIT_SYM %prec KEYWORD_USED_AS_KEYWORD {
            $$= NEW_PTN PT_bit_type(@$);
          }
|BIT_SYM field_length {
            $$= NEW_PTN PT_bit_type(@$, $2);
          }
|BOOL_SYM {
            $$= NEW_PTN PT_boolean_type(@$);
          }
|BOOLEAN_SYM {
            $$= NEW_PTN PT_boolean_type(@$);
          }
|CHAR_SYM field_length opt_charset_with_opt_binary {
            $$= NEW_PTN PT_char_type(@$, Char_type::CHAR, $2, $3.charset,
                                     $3.force_binary);
          }
|CHAR_SYM opt_charset_with_opt_binary {
            $$= NEW_PTN PT_char_type(@$, Char_type::CHAR, $2.charset,
                                     $2.force_binary);
          }
|nchar field_length opt_bin_mod {
            const CHARSET_INFO *cs= $3 ?
              get_bin_collation(national_charset_info) : national_charset_info;
            if (cs == nullptr)
              MYSQL_YYABORT;
            $$= NEW_PTN PT_char_type(@$, Char_type::CHAR, $2, cs);
            warn_about_deprecated_national(YYTHD);
          }
|nchar opt_bin_mod {
            const CHARSET_INFO *cs= $2 ?
              get_bin_collation(national_charset_info) : national_charset_info;
            if (cs == nullptr)
              MYSQL_YYABORT;
            $$= NEW_PTN PT_char_type(@$, Char_type::CHAR, cs);
            warn_about_deprecated_national(YYTHD);
          }
|BINARY_SYM field_length {
            $$= NEW_PTN PT_char_type(@$, Char_type::CHAR, $2, &my_charset_bin);
          }
|BINARY_SYM {
            $$= NEW_PTN PT_char_type(@$, Char_type::CHAR, &my_charset_bin);
          }
|varchar field_length opt_charset_with_opt_binary {
            $$= NEW_PTN PT_char_type(@$, Char_type::VARCHAR, $2, $3.charset,
                                     $3.force_binary);
          }
|nvarchar field_length opt_bin_mod {
            const CHARSET_INFO *cs= $3 ?
              get_bin_collation(national_charset_info) : national_charset_info;
            if (cs == nullptr)
              MYSQL_YYABORT;
            $$= NEW_PTN PT_char_type(@$, Char_type::VARCHAR, $2, cs);
            warn_about_deprecated_national(YYTHD);
          }
|VARBINARY_SYM field_length {
            $$= NEW_PTN PT_char_type(@$, Char_type::VARCHAR, $2, &my_charset_bin);
          }
|YEAR_SYM opt_field_length field_options {
            if ($2)
            {
              errno= 0;
              ulong length= strtoul($2, nullptr, 10);
              if (errno != 0 || length != 4)
              {
                
                my_error(ER_INVALID_YEAR_COLUMN_LENGTH, MYF(0), "YEAR");
                MYSQL_YYABORT;
              }
              push_deprecated_warn(YYTHD, "YEAR(4)", "YEAR");
            }
            if ($3 == UNSIGNED_FLAG)
            {
              push_warning(YYTHD, Sql_condition::SL_WARNING,
                           ER_WARN_DEPRECATED_SYNTAX_NO_REPLACEMENT,
                           ER_THD(YYTHD, ER_WARN_DEPRECATED_YEAR_UNSIGNED));
            }
            
            $$= NEW_PTN PT_year_type(@$);
          }
|DATE_SYM {
            $$= NEW_PTN PT_date_type(@$);
          }
|TIME_SYM type_datetime_precision {
            $$= NEW_PTN PT_time_type(@$, Time_type::TIME, $2);
          }
|TIMESTAMP_SYM type_datetime_precision {
            $$= NEW_PTN PT_timestamp_type(@$, $2);
          }
|DATETIME_SYM type_datetime_precision {
            $$= NEW_PTN PT_time_type(@$, Time_type::DATETIME, $2);
          }
|TINYBLOB_SYM {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::TINY, &my_charset_bin);
          }
|BLOB_SYM opt_field_length {
            $$= NEW_PTN PT_blob_type(@$, $2);
          }
|spatial_type 
|MEDIUMBLOB_SYM {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::MEDIUM, &my_charset_bin);
          }
|LONGBLOB_SYM {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::LONG, &my_charset_bin);
          }
|LONG_SYM VARBINARY_SYM {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::MEDIUM, &my_charset_bin);
          }
|LONG_SYM varchar opt_charset_with_opt_binary {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::MEDIUM, $3.charset,
                                     $3.force_binary);
          }
|TINYTEXT_SYN opt_charset_with_opt_binary {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::TINY, $2.charset,
                                     $2.force_binary);
          }
|TEXT_SYM opt_field_length opt_charset_with_opt_binary {
            $$= NEW_PTN PT_char_type(@$, Char_type::TEXT, $2, $3.charset,
                                     $3.force_binary);
          }
|MEDIUMTEXT_SYM opt_charset_with_opt_binary {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::MEDIUM, $2.charset,
                                     $2.force_binary);
          }
|LONGTEXT_SYM opt_charset_with_opt_binary {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::LONG, $2.charset,
                                     $2.force_binary);
          }
|ENUM_SYM '(' string_list ')' opt_charset_with_opt_binary {
            $$= NEW_PTN PT_enum_type(@$, $3, $5.charset, $5.force_binary);
          }
|SET_SYM '(' string_list ')' opt_charset_with_opt_binary {
            $$= NEW_PTN PT_set_type(@$, $3, $5.charset, $5.force_binary);
          }
|LONG_SYM opt_charset_with_opt_binary {
            $$= NEW_PTN PT_blob_type(@$, Blob_type::MEDIUM, $2.charset,
                                     $2.force_binary);
          }
|SERIAL_SYM {
            $$= NEW_PTN PT_serial_type(@$);
          }
|JSON_SYM {
            $$= NEW_PTN PT_json_type(@$);
          }
;

spatial_type:
GEOMETRY_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_GEOMETRY); }
|GEOMETRYCOLLECTION_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_GEOMETRYCOLLECTION); }
|POINT_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_POINT); }
|MULTIPOINT_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_MULTIPOINT); }
|LINESTRING_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_LINESTRING); }
|MULTILINESTRING_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_MULTILINESTRING); }
|POLYGON_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_POLYGON); }
|MULTIPOLYGON_SYM { $$= NEW_PTN PT_spacial_type(@$, Field::GEOM_MULTIPOLYGON); }
;

nchar:
NCHAR_SYM {}
|NATIONAL_SYM CHAR_SYM {}
;

varchar:
CHAR_SYM VARYING {}
|VARCHAR_SYM {}
;

nvarchar:
NATIONAL_SYM VARCHAR_SYM {}
|NVARCHAR_SYM {}
|NCHAR_SYM VARCHAR_SYM {}
|NATIONAL_SYM CHAR_SYM VARYING {}
|NCHAR_SYM VARYING {}
;

int_type:
INT_SYM { $$=Int_type::INT; }
|TINYINT_SYM { $$=Int_type::TINYINT; }
|SMALLINT_SYM { $$=Int_type::SMALLINT; }
|MEDIUMINT_SYM { $$=Int_type::MEDIUMINT; }
|BIGINT_SYM { $$=Int_type::BIGINT; }
;

real_type:
REAL_SYM {
            $$= YYTHD->variables.sql_mode & MODE_REAL_AS_FLOAT ?
              Numeric_type::FLOAT : Numeric_type::DOUBLE;
          }
|DOUBLE_SYM opt_PRECISION { $$= Numeric_type::DOUBLE; }
;

opt_PRECISION:
%empty 
|PRECISION 
;

numeric_type:
FLOAT_SYM { $$= Numeric_type::FLOAT; }
|DECIMAL_SYM { $$= Numeric_type::DECIMAL; }
|NUMERIC_SYM { $$= Numeric_type::DECIMAL; }
|FIXED_SYM { $$= Numeric_type::DECIMAL; }
;

standard_float_options:
%empty {
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|field_length {
            $$.length = $1;
            $$.dec = nullptr;
          }
;

float_options:
%empty {
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|field_length {
            $$.length= $1;
            $$.dec= nullptr;
          }
|precision 
;

precision:
'(' NUM ',' NUM ')' {
            $$.length= $2.str;
            $$.dec= $4.str;
          }
;

type_datetime_precision:
%empty { $$= nullptr; }
|'(' NUM ')' { $$= $2.str; }
;

func_datetime_precision:
%empty { $$= 0; }
|'(' ')' { $$= 0; }
|'(' NUM ')' {
             int error;
             $$= (ulong) my_strtoll10($2.str, nullptr, &error);
           }
;

field_options:
%empty { $$ = 0; }
|field_opt_list 
;

field_opt_list:
field_opt_list field_option {
            $$ = $1 | $2;
          }
|field_option 
;

field_option:
SIGNED_SYM { $$ = 0; }
|UNSIGNED_SYM { $$ = UNSIGNED_FLAG; }
|ZEROFILL_SYM {
            $$ = ZEROFILL_FLAG;
            push_warning(YYTHD, Sql_condition::SL_WARNING,
                         ER_WARN_DEPRECATED_SYNTAX_NO_REPLACEMENT,
                         ER_THD(YYTHD, ER_WARN_DEPRECATED_ZEROFILL));
          }
;

field_length:
'(' LONG_NUM ')' { $$= $2.str; }
|'(' ULONGLONG_NUM ')' { $$= $2.str; }
|'(' DECIMAL_NUM ')' { $$= $2.str; }
|'(' NUM ')' { $$= $2.str; }
;

opt_field_length:
%empty %prec PREFER_PARENTHESES { $$= nullptr;  }
|field_length 
;

opt_precision:
%empty {
            $$.length= nullptr;
            $$.dec = nullptr;
          }
|precision 
;

opt_column_attribute_list:
%empty { $$= nullptr; }
|column_attribute_list 
;

column_attribute_list:
column_attribute_list column_attribute {
            $$= $1;
            if ($2 == nullptr)
              MYSQL_YYABORT; 

            if ($2->has_constraint_enforcement()) {
              
              if ($1->back()->set_constraint_enforcement(
                      $2->is_constraint_enforced())) {
                
                YYTHD->syntax_error_at(@2);
                MYSQL_YYABORT;
              }
            } else {
              if ($$->push_back($2))
                MYSQL_YYABORT; 
            }
          }
|column_attribute {
            if ($1 == nullptr)
              MYSQL_YYABORT; 

            if ($1->has_constraint_enforcement()) {
              
              YYTHD->syntax_error_at(@1);
              MYSQL_YYABORT;
            }

            $$=
              NEW_PTN Mem_root_array<PT_column_attr_base *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
;

column_attribute:
NULL_SYM {
            $$= NEW_PTN PT_null_column_attr(@$);
          }
|not NULL_SYM {
            $$= NEW_PTN PT_not_null_column_attr(@$);
          }
|not SECONDARY_SYM {
            $$= NEW_PTN PT_secondary_column_attr(@$);
          }
|DEFAULT_SYM now_or_signed_literal {
            $$= NEW_PTN PT_default_column_attr(@$, $2);
          }
|DEFAULT_SYM '(' expr ')' {
            $$= NEW_PTN PT_generated_default_val_column_attr(@$, $3);
          }
|ON_SYM UPDATE_SYM now {
            $$= NEW_PTN PT_on_update_column_attr(@$, static_cast<uint8>($3));
          }
|AUTO_INC {
            $$= NEW_PTN PT_auto_increment_column_attr(@$);
          }
|SERIAL_SYM DEFAULT_SYM VALUE_SYM {
            $$= NEW_PTN PT_serial_default_value_column_attr(@$);
          }
|opt_primary KEY_SYM {
            $$= NEW_PTN PT_primary_key_column_attr(@$);
          }
|UNIQUE_SYM {
            $$= NEW_PTN PT_unique_key_column_attr(@$);
          }
|UNIQUE_SYM KEY_SYM {
            $$= NEW_PTN PT_unique_key_column_attr(@$);
          }
|COMMENT_SYM TEXT_STRING_sys {
            $$= NEW_PTN PT_comment_column_attr(@$, to_lex_cstring($2));
          }
|COLLATE_SYM collation_name {
            $$= NEW_PTN PT_collate_column_attr(@$, $2);
          }
|COLUMN_FORMAT_SYM column_format {
            $$= NEW_PTN PT_column_format_column_attr(@$, $2);
          }
|STORAGE_SYM storage_media {
            $$= NEW_PTN PT_storage_media_column_attr(@$, $2);
          }
|SRID_SYM real_ulonglong_num {
            if ($2 > std::numeric_limits<gis::srid_t>::max())
            {
              my_error(ER_DATA_OUT_OF_RANGE, MYF(0), "SRID", "SRID");
              MYSQL_YYABORT;
            }
            $$= NEW_PTN PT_srid_column_attr(@$, static_cast<gis::srid_t>($2));
          }
|opt_constraint_name check_constraint {
            $$= NEW_PTN PT_check_constraint_column_attr(@$, $1, $2);
          }
|constraint_enforcement {
            $$ = NEW_PTN PT_constraint_enforcement_attr(@$, $1);
          }
|ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_column_engine_attribute(YYMEM_ROOT, $3);
          }
|SECONDARY_ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_column_secondary_engine_attribute(YYMEM_ROOT, $3);
          }
|visibility {
            $$ = NEW_PTN PT_column_visibility_attr(@$, $1);
          }
;

column_format:
DEFAULT_SYM { $$= COLUMN_FORMAT_TYPE_DEFAULT; }
|FIXED_SYM { $$= COLUMN_FORMAT_TYPE_FIXED; }
|DYNAMIC_SYM { $$= COLUMN_FORMAT_TYPE_DYNAMIC; }
;

storage_media:
DEFAULT_SYM { $$= HA_SM_DEFAULT; }
|DISK_SYM { $$= HA_SM_DISK; }
|MEMORY_SYM { $$= HA_SM_MEMORY; }
;

now:
NOW_SYM func_datetime_precision {
            $$= $2;
          }
;

now_or_signed_literal:
now {
            $$= NEW_PTN Item_func_now_local(@$, static_cast<uint8>($1));
          }
|signed_literal_or_null 
;

character_set:
CHAR_SYM SET_SYM 
|CHARSET 
;

charset_name:
ident_or_text {
            if (!($$=get_charset_by_csname($1.str,MY_CS_PRIMARY,MYF(0))))
            {
              my_error(ER_UNKNOWN_CHARACTER_SET, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
            YYLIP->warn_on_deprecated_charset($$, $1.str);
          }
|BINARY_SYM { $$= &my_charset_bin; }
;

opt_load_data_charset:
%empty { $$= nullptr; }
|character_set charset_name { $$ = $2; }
;

old_or_new_charset_name:
ident_or_text {
            if (!($$=get_charset_by_csname($1.str,MY_CS_PRIMARY,MYF(0))) &&
                !($$=get_old_charset_by_name($1.str)))
            {
              my_error(ER_UNKNOWN_CHARACTER_SET, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
          }
|BINARY_SYM { $$= &my_charset_bin; }
;

old_or_new_charset_name_or_default:
old_or_new_charset_name { $$=$1;   }
|DEFAULT_SYM { $$=nullptr; }
;

collation_name:
ident_or_text {
            if (!($$= mysqld_collation_get_by_name($1.str)))
              MYSQL_YYABORT;
            YYLIP->warn_on_deprecated_collation($$);
          }
|BINARY_SYM { $$= &my_charset_bin; }
;

opt_collate:
%empty { $$ = nullptr; }
|COLLATE_SYM collation_name { $$ = $2; }
;

opt_default:
%empty {}
|DEFAULT_SYM {}
;

ascii:
ASCII_SYM {
          push_deprecated_warn(YYTHD, "ASCII", "CHARACTER SET charset_name");
          $$= &my_charset_latin1;
        }
|BINARY_SYM ASCII_SYM {
            warn_about_deprecated_binary(YYTHD);
            push_deprecated_warn(YYTHD, "ASCII", "CHARACTER SET charset_name");
            $$= &my_charset_latin1_bin;
        }
|ASCII_SYM BINARY_SYM {
            push_deprecated_warn(YYTHD, "ASCII", "CHARACTER SET charset_name");
            warn_about_deprecated_binary(YYTHD);
            $$= &my_charset_latin1_bin;
        }
;

unicode:
UNICODE_SYM {
            push_deprecated_warn(YYTHD, "UNICODE", "CHARACTER SET charset_name");
            if (!($$= get_charset_by_csname("ucs2", MY_CS_PRIMARY,MYF(0))))
            {
              my_error(ER_UNKNOWN_CHARACTER_SET, MYF(0), "ucs2");
              MYSQL_YYABORT;
            }
          }
|UNICODE_SYM BINARY_SYM {
            push_deprecated_warn(YYTHD, "UNICODE", "CHARACTER SET charset_name");
            warn_about_deprecated_binary(YYTHD);
            if (!($$= mysqld_collation_get_by_name("ucs2_bin")))
              MYSQL_YYABORT;
          }
|BINARY_SYM UNICODE_SYM {
            warn_about_deprecated_binary(YYTHD);
            push_deprecated_warn(YYTHD, "UNICODE", "CHARACTER SET charset_name");
            if (!($$= mysqld_collation_get_by_name("ucs2_bin")))
              my_error(ER_UNKNOWN_COLLATION, MYF(0), "ucs2_bin");
          }
;

opt_charset_with_opt_binary:
%empty {
            $$.charset= nullptr;
            $$.force_binary= false;
          }
|ascii {
            $$.charset= $1;
            $$.force_binary= false;
          }
|unicode {
            $$.charset= $1;
            $$.force_binary= false;
          }
|BYTE_SYM {
            $$.charset= &my_charset_bin;
            $$.force_binary= false;
          }
|character_set charset_name opt_bin_mod {
            $$.charset= $3 ? get_bin_collation($2) : $2;
            if ($$.charset == nullptr)
              MYSQL_YYABORT;
            $$.force_binary= false;
          }
|BINARY_SYM {
            warn_about_deprecated_binary(YYTHD);
            $$.charset= nullptr;
            $$.force_binary= true;
          }
|BINARY_SYM character_set charset_name {
            warn_about_deprecated_binary(YYTHD);
            $$.charset= get_bin_collation($3);
            if ($$.charset == nullptr)
              MYSQL_YYABORT;
            $$.force_binary= false;
          }
;

opt_bin_mod:
%empty { $$= false; }
|BINARY_SYM {
            warn_about_deprecated_binary(YYTHD);
            $$= true;
          }
;

ws_num_codepoints:
'(' real_ulong_num {
          if ($2 == 0)
          {
            YYTHD->syntax_error();
            MYSQL_YYABORT;
          }
        }')' { $$= $2; }
;

opt_primary:
%empty 
|PRIMARY_SYM 
;

references:
REFERENCES table_ident opt_ref_list opt_match_clause opt_on_update_delete {
            $$.table_name= $2;
            $$.reference_list= $3;
            $$.fk_match_option= $4;
            $$.fk_update_opt= $5.fk_update_opt;
            $$.fk_delete_opt= $5.fk_delete_opt;
          }
;

opt_ref_list:
%empty { $$= nullptr; }
|'(' reference_list ')' { $$= $2; }
;

reference_list:
reference_list ',' ident {
            $$= $1;
            auto key= NEW_PTN Key_part_spec(to_lex_cstring($3), 0, ORDER_ASC);
            if (key == nullptr || $$->push_back(key))
              MYSQL_YYABORT;
          }
|ident {
            $$= NEW_PTN List<Key_part_spec>;
            auto key= NEW_PTN Key_part_spec(to_lex_cstring($1), 0, ORDER_ASC);
            if ($$ == nullptr || key == nullptr || $$->push_back(key))
              MYSQL_YYABORT;
          }
;

opt_match_clause:
%empty { $$= FK_MATCH_UNDEF; }
|MATCH FULL { $$= FK_MATCH_FULL; }
|MATCH PARTIAL { $$= FK_MATCH_PARTIAL; }
|MATCH SIMPLE_SYM { $$= FK_MATCH_SIMPLE; }
;

opt_on_update_delete:
%empty {
            $$.fk_update_opt= FK_OPTION_UNDEF;
            $$.fk_delete_opt= FK_OPTION_UNDEF;
          }
|ON_SYM UPDATE_SYM delete_option {
            $$.fk_update_opt= $3;
            $$.fk_delete_opt= FK_OPTION_UNDEF;
          }
|ON_SYM DELETE_SYM delete_option {
            $$.fk_update_opt= FK_OPTION_UNDEF;
            $$.fk_delete_opt= $3;
          }
|ON_SYM UPDATE_SYM delete_option ON_SYM DELETE_SYM delete_option {
            $$.fk_update_opt= $3;
            $$.fk_delete_opt= $6;
          }
|ON_SYM DELETE_SYM delete_option ON_SYM UPDATE_SYM delete_option {
            $$.fk_update_opt= $6;
            $$.fk_delete_opt= $3;
          }
;

delete_option:
RESTRICT { $$= FK_OPTION_RESTRICT; }
|CASCADE { $$= FK_OPTION_CASCADE; }
|SET_SYM NULL_SYM { $$= FK_OPTION_SET_NULL; }
|NO_SYM ACTION { $$= FK_OPTION_NO_ACTION; }
|SET_SYM DEFAULT_SYM { $$= FK_OPTION_DEFAULT;  }
;

constraint_key_type:
PRIMARY_SYM KEY_SYM { $$= KEYTYPE_PRIMARY; }
|UNIQUE_SYM opt_key_or_index { $$= KEYTYPE_UNIQUE; }
;

key_or_index:
KEY_SYM {}
|INDEX_SYM {}
;

opt_key_or_index:
%empty {}
|key_or_index 
;

keys_or_index:
KEYS {}
|INDEX_SYM {}
|INDEXES {}
;

opt_unique:
%empty { $$= KEYTYPE_MULTIPLE; }
|UNIQUE_SYM { $$= KEYTYPE_UNIQUE; }
;

opt_fulltext_index_options:
%empty { $$.init(YYMEM_ROOT); }
|fulltext_index_options 
;

fulltext_index_options:
fulltext_index_option {
            $$.init(YYMEM_ROOT);
            if ($$.push_back($1))
              MYSQL_YYABORT; 
          }
|fulltext_index_options fulltext_index_option {
            if ($1.push_back($2))
              MYSQL_YYABORT; 
            $$= $1;
          }
;

fulltext_index_option:
common_index_option 
|WITH PARSER_SYM IDENT_sys {
            LEX_CSTRING plugin_name= {$3.str, $3.length};
            if (!plugin_is_ready(plugin_name, MYSQL_FTPARSER_PLUGIN))
            {
              my_error(ER_FUNCTION_NOT_DEFINED, MYF(0), $3.str);
              MYSQL_YYABORT;
            }
            else
              $$= NEW_PTN PT_fulltext_index_parser_name(@$, to_lex_cstring($3));
          }
;

opt_spatial_index_options:
%empty { $$.init(YYMEM_ROOT); }
|spatial_index_options 
;

spatial_index_options:
spatial_index_option {
            $$.init(YYMEM_ROOT);
            if ($$.push_back($1))
              MYSQL_YYABORT; 
          }
|spatial_index_options spatial_index_option {
            if ($1.push_back($2))
              MYSQL_YYABORT; 
            $$= $1;
          }
;

spatial_index_option:
common_index_option 
;

opt_index_options:
%empty { $$.init(YYMEM_ROOT); }
|index_options 
;

index_options:
index_option {
            $$.init(YYMEM_ROOT);
            if ($$.push_back($1))
              MYSQL_YYABORT; 
          }
|index_options index_option {
            if ($1.push_back($2))
              MYSQL_YYABORT; 
            $$= $1;
          }
;

index_option:
common_index_option { $$= $1; }
|index_type_clause { $$= $1; }
;

common_index_option:
KEY_BLOCK_SIZE opt_equal ulong_num { $$= NEW_PTN PT_block_size(@$, $3); }
|COMMENT_SYM TEXT_STRING_sys {
            $$= NEW_PTN PT_index_comment(@$, to_lex_cstring($2));
          }
|visibility {
            $$= NEW_PTN PT_index_visibility(@$, $1);
          }
|ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_index_engine_attribute(YYMEM_ROOT, $3);
          }
|SECONDARY_ENGINE_ATTRIBUTE_SYM opt_equal json_attribute {
            $$ = make_index_secondary_engine_attribute(YYMEM_ROOT, $3);
          }
;

opt_index_name_and_type:
opt_ident { $$= {$1, nullptr}; }
|opt_ident USING index_type { $$= {$1, NEW_PTN PT_index_type(@$, $3)}; }
|ident TYPE_SYM index_type { $$= {$1, NEW_PTN PT_index_type(@$, $3)}; }
;

opt_index_type_clause:
%empty { $$ = nullptr; }
|index_type_clause 
;

index_type_clause:
USING index_type { $$= NEW_PTN PT_index_type(@$, $2); }
|TYPE_SYM index_type { $$= NEW_PTN PT_index_type(@$, $2); }
;

visibility:
VISIBLE_SYM { $$= true; }
|INVISIBLE_SYM { $$= false; }
;

index_type:
BTREE_SYM { $$= HA_KEY_ALG_BTREE; }
|RTREE_SYM { $$= HA_KEY_ALG_RTREE; }
|HASH_SYM { $$= HA_KEY_ALG_HASH; }
;

key_list:
key_list ',' key_part {
            if ($1->push_back($3))
              MYSQL_YYABORT; 
            $$= $1;
          }
|key_part {
            
            $$= NEW_PTN List<PT_key_part_specification>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
;

key_part:
ident opt_ordering_direction {
            $$= NEW_PTN PT_key_part_specification(@$, to_lex_cstring($1), $2, 0);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|ident '(' NUM ')' opt_ordering_direction {
            int key_part_length= atoi($3.str);
            if (!key_part_length)
            {
              my_error(ER_KEY_PART_0, MYF(0), $1.str);
            }
            $$= NEW_PTN PT_key_part_specification(@$, to_lex_cstring($1), $5,
                                                  key_part_length);
            if ($$ == nullptr)
              MYSQL_YYABORT; 
          }
;

key_list_with_expression:
key_list_with_expression ',' key_part_with_expression {
            if ($1->push_back($3))
              MYSQL_YYABORT; 
            $$= $1;
          }
|key_part_with_expression {
            
            $$= NEW_PTN List<PT_key_part_specification>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
;

key_part_with_expression:
key_part 
|'(' expr ')' opt_ordering_direction {
            $$= NEW_PTN PT_key_part_specification(@$, $2, $4);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

opt_ident:
%empty { $$= NULL_STR; }
|ident 
;

string_list:
text_string {
            $$= NEW_PTN List<String>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|string_list ',' text_string {
            if ($$->push_back($3))
              MYSQL_YYABORT;
          }
;

alter_table_stmt:
ALTER TABLE_SYM table_ident opt_alter_table_actions {
            $$= NEW_PTN PT_alter_table_stmt(
                  @$,
                  YYMEM_ROOT,
                  $3,
                  $4.actions,
                  $4.flags.algo.get_or_default(),
                  $4.flags.lock.get_or_default(),
                  $4.flags.validation.get_or_default());
          }
|ALTER TABLE_SYM table_ident standalone_alter_table_action {
            $$= NEW_PTN PT_alter_table_standalone_stmt(
                  @$,
                  YYMEM_ROOT,
                  $3,
                  $4.action,
                  $4.flags.algo.get_or_default(),
                  $4.flags.lock.get_or_default(),
                  $4.flags.validation.get_or_default());
          }
;

alter_database_stmt:
ALTER DATABASE ident_or_empty {
            Lex->create_info= YYTHD->alloc_typed<HA_CREATE_INFO>();
            if (Lex->create_info == nullptr)
              MYSQL_YYABORT; 
            Lex->create_info->default_table_charset= nullptr;
            Lex->create_info->used_fields= 0;
          }alter_database_options {
            LEX *lex=Lex;
            lex->sql_command=SQLCOM_ALTER_DB;
            lex->name= $3;
            if (lex->name.str == nullptr &&
                lex->copy_db_to(&lex->name.str, &lex->name.length))
              MYSQL_YYABORT;
          }
;

alter_procedure_stmt:
ALTER PROCEDURE_SYM sp_name {
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_NO_DROP_SP, MYF(0), "PROCEDURE");
              MYSQL_YYABORT;
            }
            memset(&lex->sp_chistics, 0, sizeof(st_sp_chistics));
          }sp_a_chistics {
            LEX *lex=Lex;

            lex->sql_command= SQLCOM_ALTER_PROCEDURE;
            lex->spname= $3;
            MAKE_CMD_DDL_DUMMY();
          }
;

alter_function_stmt:
ALTER FUNCTION_SYM sp_name {
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_NO_DROP_SP, MYF(0), "FUNCTION");
              MYSQL_YYABORT;
            }
            memset(&lex->sp_chistics, 0, sizeof(st_sp_chistics));
          }sp_a_chistics {
            LEX *lex=Lex;

            lex->sql_command= SQLCOM_ALTER_FUNCTION;
            lex->spname= $3;
            MAKE_CMD_DDL_DUMMY();
          }
;

alter_view_stmt:
ALTER view_algorithm definer_opt {
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_BADSTATEMENT, MYF(0), "ALTER VIEW");
              MYSQL_YYABORT;
            }
            lex->create_view_mode= enum_view_create_mode::VIEW_ALTER;
          }view_tail {
            MAKE_CMD_DDL_DUMMY();
          }
|ALTER definer_opt {
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_BADSTATEMENT, MYF(0), "ALTER VIEW");
              MYSQL_YYABORT;
            }
            lex->create_view_algorithm= VIEW_ALGORITHM_UNDEFINED;
            lex->create_view_mode= enum_view_create_mode::VIEW_ALTER;
          }view_tail {
            MAKE_CMD_DDL_DUMMY();
          }
;

alter_event_stmt:
ALTER definer_opt EVENT_SYM sp_name {
            

            if (!(Lex->event_parse_data= new (YYTHD->mem_root) Event_parse_data()))
              MYSQL_YYABORT;
            Lex->event_parse_data->identifier= $4;

            Lex->sql_command= SQLCOM_ALTER_EVENT;
            MAKE_CMD_DDL_DUMMY();
          }ev_alter_on_schedule_completion opt_ev_rename_to opt_ev_status opt_ev_comment opt_ev_sql_stmt {
            if (!($6 || $7 || $8 || $9 || $10))
            {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
            
            Lex->sql_command= SQLCOM_ALTER_EVENT;

            
            assert(Lex->m_sql_cmd->sql_cmd_type() == SQL_CMD_DDL);
            assert(Lex->m_sql_cmd->sql_command_code() == SQLCOM_ALTER_EVENT);
          }
;

alter_logfile_stmt:
ALTER LOGFILE_SYM GROUP_SYM ident ADD lg_undofile opt_alter_logfile_group_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($7 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $7))
                MYSQL_YYABORT; 
            }

            Lex->m_sql_cmd= NEW_PTN Sql_cmd_logfile_group{ALTER_LOGFILE_GROUP,
                                                          $4, pc, $6};
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT;  

            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }

alter_tablespace_stmt:
ALTER TABLESPACE_SYM ident ADD ts_datafile opt_alter_tablespace_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($6 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $6))
                MYSQL_YYABORT; 
            }

            Lex->m_sql_cmd= NEW_PTN Sql_cmd_alter_tablespace_add_datafile{$3, $5, pc};
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT;  

            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
|ALTER TABLESPACE_SYM ident DROP ts_datafile opt_alter_tablespace_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($6 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $6))
                MYSQL_YYABORT; 
            }

            Lex->m_sql_cmd=
              NEW_PTN Sql_cmd_alter_tablespace_drop_datafile{$3, $5, pc};
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT;  

            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
|ALTER TABLESPACE_SYM ident RENAME TO_SYM ident {
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_alter_tablespace_rename{$3, $6};
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT; 

            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
|ALTER TABLESPACE_SYM ident alter_tablespace_option_list {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT; 

            if ($4 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $4))
                MYSQL_YYABORT;
            }

            Lex->m_sql_cmd=
              NEW_PTN Sql_cmd_alter_tablespace{$3, pc};
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT; 

            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
;

alter_undo_tablespace_stmt:
ALTER UNDO_SYM TABLESPACE_SYM ident SET_SYM undo_tablespace_state opt_undo_tablespace_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT; 

            if ($7 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $7))
                MYSQL_YYABORT;
            }

            auto cmd= NEW_PTN Sql_cmd_alter_undo_tablespace{
              ALTER_UNDO_TABLESPACE, $4,
              {nullptr, 0}, pc, $6};
            if (!cmd)
              MYSQL_YYABORT; 
            Lex->m_sql_cmd= cmd;
            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
;

alter_server_stmt:
ALTER SERVER_SYM ident_or_text OPTIONS_SYM '(' server_options_list ')' {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_ALTER_SERVER;
            lex->server_options.m_server_name= $3;
            lex->m_sql_cmd=
              NEW_PTN Sql_cmd_alter_server(&Lex->server_options);
          }
;

alter_user_stmt:
alter_user_command alter_user_list require_clause connect_options opt_account_lock_password_expire_options opt_user_attribute 
|alter_user_command user_func identified_by_random_password opt_replace_password opt_retain_current_password {
            $2->first_factor_auth_info = *$3;

            if ($4.str != nullptr) {
              $2->current_auth = $4;
              $2->uses_replace_clause = true;
            }
            $2->discard_old_password = false;
            $2->retain_current_password = $5;
          }
|alter_user_command user_func identified_by_password opt_replace_password opt_retain_current_password {
            $2->first_factor_auth_info = *$3;

            if ($4.str != nullptr) {
              $2->current_auth = $4;
              $2->uses_replace_clause = true;
            }
            $2->discard_old_password = false;
            $2->retain_current_password = $5;
          }
|alter_user_command user_func DISCARD_SYM OLD_SYM PASSWORD {
            $2->discard_old_password = true;
            $2->retain_current_password = false;
          }
|alter_user_command user DEFAULT_SYM ROLE_SYM ALL {
            List<LEX_USER> *users= new (YYMEM_ROOT) List<LEX_USER>;
            if (users == nullptr || users->push_back($2))
              MYSQL_YYABORT;
            List<LEX_USER> *role_list= new (YYMEM_ROOT) List<LEX_USER>;
            auto *tmp=
                NEW_PTN PT_alter_user_default_role(@$, Lex->drop_if_exists,
                                                   users, role_list,
                                                   role_enum::ROLE_ALL);
              MAKE_CMD(tmp);
          }
|alter_user_command user DEFAULT_SYM ROLE_SYM NONE_SYM {
            List<LEX_USER> *users= new (YYMEM_ROOT) List<LEX_USER>;
            if (users == nullptr || users->push_back($2))
              MYSQL_YYABORT;
            List<LEX_USER> *role_list= new (YYMEM_ROOT) List<LEX_USER>;
            auto *tmp=
                NEW_PTN PT_alter_user_default_role(@$, Lex->drop_if_exists,
                                                   users, role_list,
                                                   role_enum::ROLE_NONE);
              MAKE_CMD(tmp);
          }
|alter_user_command user DEFAULT_SYM ROLE_SYM role_list {
            List<LEX_USER> *users= new (YYMEM_ROOT) List<LEX_USER>;
            if (users == nullptr || users->push_back($2))
              MYSQL_YYABORT;
            auto *tmp=
              NEW_PTN PT_alter_user_default_role(@$, Lex->drop_if_exists,
                                                 users, $5,
                                                 role_enum::ROLE_NAME);
            MAKE_CMD(tmp);
          }
|alter_user_command user opt_user_registration {
            if ($2->mfa_list.push_back($3))
              MYSQL_YYABORT;  
            LEX *lex=Lex;
            lex->users_list.push_front ($2);
          }
|alter_user_command user_func opt_user_registration {
            if ($2->mfa_list.push_back($3))
              MYSQL_YYABORT;  
          }
;

opt_replace_password:
%empty { $$ = LEX_CSTRING{nullptr, 0}; }
|REPLACE_SYM TEXT_STRING_password { $$ = to_lex_cstring($2); }
;

alter_resource_group_stmt:
ALTER RESOURCE_SYM GROUP_SYM ident opt_resource_group_vcpu_list opt_resource_group_priority opt_resource_group_enable_disable opt_force {
            $$= NEW_PTN PT_alter_resource_group(@$, to_lex_cstring($4),
                                                $5, $6, $7, $8);
          }
;

alter_user_command:
ALTER USER if_exists {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_ALTER_USER;
            lex->drop_if_exists= $3;
            MAKE_CMD_DCL_DUMMY();
          }
;

opt_user_attribute:
%empty {
            LEX *lex= Lex;
            lex->alter_user_attribute =
              enum_alter_user_attribute::ALTER_USER_COMMENT_NOT_USED;
          }
|ATTRIBUTE_SYM TEXT_STRING_literal {
            LEX *lex= Lex;
            lex->alter_user_attribute =
              enum_alter_user_attribute::ALTER_USER_ATTRIBUTE;
            lex->alter_user_comment_text = $2;
          }
|COMMENT_SYM TEXT_STRING_literal {
            LEX *lex= Lex;
            lex->alter_user_attribute =
              enum_alter_user_attribute::ALTER_USER_COMMENT;
            lex->alter_user_comment_text = $2;
          }
;

opt_account_lock_password_expire_options:
%empty {}
|opt_account_lock_password_expire_option_list 
;

opt_account_lock_password_expire_option_list:
opt_account_lock_password_expire_option 
|opt_account_lock_password_expire_option_list opt_account_lock_password_expire_option 
;

opt_account_lock_password_expire_option:
ACCOUNT_SYM UNLOCK_SYM {
            LEX *lex=Lex;
            lex->alter_password.update_account_locked_column= true;
            lex->alter_password.account_locked= false;
          }
|ACCOUNT_SYM LOCK_SYM {
            LEX *lex=Lex;
            lex->alter_password.update_account_locked_column= true;
            lex->alter_password.account_locked= true;
          }
|PASSWORD EXPIRE_SYM {
            LEX *lex= Lex;
            lex->alter_password.expire_after_days= 0;
            lex->alter_password.update_password_expired_column= true;
            lex->alter_password.update_password_expired_fields= true;
            lex->alter_password.use_default_password_lifetime= true;
          }
|PASSWORD EXPIRE_SYM INTERVAL_SYM real_ulong_num DAY_SYM {
            LEX *lex= Lex;
            if ($4 == 0 || $4 > UINT_MAX16)
            {
              char buf[MAX_BIGINT_WIDTH + 1];
              snprintf(buf, sizeof(buf), "%lu", $4);
              my_error(ER_WRONG_VALUE, MYF(0), "DAY", buf);
              MYSQL_YYABORT;
            }
            lex->alter_password.expire_after_days= $4;
            lex->alter_password.update_password_expired_column= false;
            lex->alter_password.update_password_expired_fields= true;
            lex->alter_password.use_default_password_lifetime= false;
          }
|PASSWORD EXPIRE_SYM NEVER_SYM {
            LEX *lex= Lex;
            lex->alter_password.expire_after_days= 0;
            lex->alter_password.update_password_expired_column= false;
            lex->alter_password.update_password_expired_fields= true;
            lex->alter_password.use_default_password_lifetime= false;
          }
|PASSWORD EXPIRE_SYM DEFAULT_SYM {
            LEX *lex= Lex;
            lex->alter_password.expire_after_days= 0;
            lex->alter_password.update_password_expired_column= false;
            Lex->alter_password.update_password_expired_fields= true;
            lex->alter_password.use_default_password_lifetime= true;
          }
|PASSWORD HISTORY_SYM real_ulong_num {
            LEX *lex= Lex;
            lex->alter_password.password_history_length= $3;
            lex->alter_password.update_password_history= true;
            lex->alter_password.use_default_password_history= false;
          }
|PASSWORD HISTORY_SYM DEFAULT_SYM {
            LEX *lex= Lex;
            lex->alter_password.password_history_length= 0;
            lex->alter_password.update_password_history= true;
            lex->alter_password.use_default_password_history= true;
          }
|PASSWORD REUSE_SYM INTERVAL_SYM real_ulong_num DAY_SYM {
            LEX *lex= Lex;
            lex->alter_password.password_reuse_interval= $4;
            lex->alter_password.update_password_reuse_interval= true;
            lex->alter_password.use_default_password_reuse_interval= false;
          }
|PASSWORD REUSE_SYM INTERVAL_SYM DEFAULT_SYM {
            LEX *lex= Lex;
            lex->alter_password.password_reuse_interval= 0;
            lex->alter_password.update_password_reuse_interval= true;
            lex->alter_password.use_default_password_reuse_interval= true;
          }
|PASSWORD REQUIRE_SYM CURRENT_SYM {
            LEX *lex= Lex;
            lex->alter_password.update_password_require_current=
                Lex_acl_attrib_udyn::YES;
          }
|PASSWORD REQUIRE_SYM CURRENT_SYM DEFAULT_SYM {
            LEX *lex= Lex;
            lex->alter_password.update_password_require_current=
                Lex_acl_attrib_udyn::DEFAULT;
          }
|PASSWORD REQUIRE_SYM CURRENT_SYM OPTIONAL_SYM {
            LEX *lex= Lex;
            lex->alter_password.update_password_require_current=
                Lex_acl_attrib_udyn::NO;
          }
|FAILED_LOGIN_ATTEMPTS_SYM real_ulong_num {
            LEX *lex= Lex;
            if ($2 > INT_MAX16) {
              char buf[MAX_BIGINT_WIDTH + 1];
              snprintf(buf, sizeof(buf), "%lu", $2);
              my_error(ER_WRONG_VALUE, MYF(0), "FAILED_LOGIN_ATTEMPTS", buf);
              MYSQL_YYABORT;
            }
            lex->alter_password.update_failed_login_attempts= true;
            lex->alter_password.failed_login_attempts= $2;
          }
|PASSWORD_LOCK_TIME_SYM real_ulong_num {
            LEX *lex= Lex;
            if ($2 > INT_MAX16) {
              char buf[MAX_BIGINT_WIDTH + 1];
              snprintf(buf, sizeof(buf), "%lu", $2);
              my_error(ER_WRONG_VALUE, MYF(0), "PASSWORD_LOCK_TIME", buf);
              MYSQL_YYABORT;
            }
            lex->alter_password.update_password_lock_time= true;
            lex->alter_password.password_lock_time= $2;
          }
|PASSWORD_LOCK_TIME_SYM UNBOUNDED_SYM {
            LEX *lex= Lex;
            lex->alter_password.update_password_lock_time= true;
            lex->alter_password.password_lock_time= -1;
          }
;

connect_options:
%empty {}
|WITH connect_option_list 
;

connect_option_list:
connect_option_list connect_option {}
|connect_option {}
;

connect_option:
MAX_QUERIES_PER_HOUR ulong_num {
            LEX *lex=Lex;
            lex->mqh.questions=$2;
            lex->mqh.specified_limits|= USER_RESOURCES::QUERIES_PER_HOUR;
          }
|MAX_UPDATES_PER_HOUR ulong_num {
            LEX *lex=Lex;
            lex->mqh.updates=$2;
            lex->mqh.specified_limits|= USER_RESOURCES::UPDATES_PER_HOUR;
          }
|MAX_CONNECTIONS_PER_HOUR ulong_num {
            LEX *lex=Lex;
            lex->mqh.conn_per_hour= $2;
            lex->mqh.specified_limits|= USER_RESOURCES::CONNECTIONS_PER_HOUR;
          }
|MAX_USER_CONNECTIONS_SYM ulong_num {
            LEX *lex=Lex;
            lex->mqh.user_conn= $2;
            lex->mqh.specified_limits|= USER_RESOURCES::USER_CONNECTIONS;
          }
;

user_func:
USER '(' ')' {
            
            LEX_USER *curr_user;
            if (!(curr_user= LEX_USER::alloc(YYTHD)))
              MYSQL_YYABORT;

            Lex->users_list.push_back(curr_user);
            $$= curr_user;
          }
;

ev_alter_on_schedule_completion:
%empty { $$= 0;}
|ON_SYM SCHEDULE_SYM ev_schedule_time { $$= 1; }
|ev_on_completion { $$= 1; }
|ON_SYM SCHEDULE_SYM ev_schedule_time ev_on_completion { $$= 1; }
;

opt_ev_rename_to:
%empty { $$= 0;}
|RENAME TO_SYM sp_name {
            
            Lex->spname= $3;
            $$= 1;
          }
;

opt_ev_sql_stmt:
%empty { $$= 0;}
|DO_SYM ev_sql_stmt { $$= 1; }
;

ident_or_empty:
%empty { $$.str= nullptr; $$.length= 0; }
|ident { $$= $1; }
;

opt_alter_table_actions:
opt_alter_command_list 
|opt_alter_command_list alter_table_partition_options {
            $$= $1;
            if ($$.actions == nullptr)
            {
              $$.actions= NEW_PTN Mem_root_array<PT_ddl_table_option *>(YYMEM_ROOT);
              if ($$.actions == nullptr)
                MYSQL_YYABORT; 
            }
            if ($$.actions->push_back($2))
              MYSQL_YYABORT; 
          }
;

standalone_alter_table_action:
standalone_alter_commands {
            $$.flags.init();
            $$.action= $1;
          }
|alter_commands_modifier_list ',' standalone_alter_commands {
            $$.flags= $1;
            $$.action= $3;
          }
;

alter_table_partition_options:
partition_clause {
            $$= NEW_PTN PT_alter_table_partition_by(@$, $1);
          }
|REMOVE_SYM PARTITIONING_SYM {
            $$= NEW_PTN PT_alter_table_remove_partitioning(@$);
          }
;

opt_alter_command_list:
%empty {
            $$.flags.init();
            $$.actions= nullptr;
          }
|alter_commands_modifier_list {
            $$.flags= $1;
            $$.actions= nullptr;
          }
|alter_list 
|alter_commands_modifier_list ',' alter_list {
            $$.flags= $1;
            $$.flags.merge($3.flags);
            $$.actions= $3.actions;
          }
;

standalone_alter_commands:
DISCARD_SYM TABLESPACE_SYM {
            $$= NEW_PTN PT_alter_table_discard_tablespace(@$);
          }
|IMPORT TABLESPACE_SYM {
            $$= NEW_PTN PT_alter_table_import_tablespace(@$);
          }
|ADD PARTITION_SYM opt_no_write_to_binlog {
            $$= NEW_PTN PT_alter_table_add_partition(@$, $3);
          }
|ADD PARTITION_SYM opt_no_write_to_binlog '(' part_def_list ')' {
            $$= NEW_PTN PT_alter_table_add_partition_def_list(@$, $3, $5);
          }
|ADD PARTITION_SYM opt_no_write_to_binlog PARTITIONS_SYM real_ulong_num {
            $$= NEW_PTN PT_alter_table_add_partition_num(@$, $3, $5);
          }
|DROP PARTITION_SYM ident_string_list {
            $$= NEW_PTN PT_alter_table_drop_partition(@$, *$3);
          }
|REBUILD_SYM PARTITION_SYM opt_no_write_to_binlog all_or_alt_part_name_list {
            $$= NEW_PTN PT_alter_table_rebuild_partition(@$, $3, $4);
          }
|OPTIMIZE PARTITION_SYM opt_no_write_to_binlog all_or_alt_part_name_list {
            $$= NEW_PTN PT_alter_table_optimize_partition(@$, $3, $4);
          }
|ANALYZE_SYM PARTITION_SYM opt_no_write_to_binlog all_or_alt_part_name_list {
            $$= NEW_PTN PT_alter_table_analyze_partition(@$, $3, $4);
          }
|CHECK_SYM PARTITION_SYM all_or_alt_part_name_list opt_mi_check_types {
            $$= NEW_PTN PT_alter_table_check_partition(@$, $3,
                                                       $4.flags, $4.sql_flags);
          }
|REPAIR PARTITION_SYM opt_no_write_to_binlog all_or_alt_part_name_list opt_mi_repair_types {
            $$= NEW_PTN PT_alter_table_repair_partition(@$, $3, $4,
                                                        $5.flags, $5.sql_flags);
          }
|COALESCE PARTITION_SYM opt_no_write_to_binlog real_ulong_num {
            $$= NEW_PTN PT_alter_table_coalesce_partition(@$, $3, $4);
          }
|TRUNCATE_SYM PARTITION_SYM all_or_alt_part_name_list {
            $$= NEW_PTN PT_alter_table_truncate_partition(@$, $3);
          }
|REORGANIZE_SYM PARTITION_SYM opt_no_write_to_binlog {
            $$= NEW_PTN PT_alter_table_reorganize_partition(@$, $3);
          }
|REORGANIZE_SYM PARTITION_SYM opt_no_write_to_binlog ident_string_list INTO '(' part_def_list ')' {
            $$= NEW_PTN PT_alter_table_reorganize_partition_into(@$, $3, *$4, $7);
          }
|EXCHANGE_SYM PARTITION_SYM ident WITH TABLE_SYM table_ident opt_with_validation {
            $$= NEW_PTN PT_alter_table_exchange_partition(@$, $3, $6, $7);
          }
|DISCARD_SYM PARTITION_SYM all_or_alt_part_name_list TABLESPACE_SYM {
            $$= NEW_PTN PT_alter_table_discard_partition_tablespace(@$, $3);
          }
|IMPORT PARTITION_SYM all_or_alt_part_name_list TABLESPACE_SYM {
            $$= NEW_PTN PT_alter_table_import_partition_tablespace(@$, $3);
          }
|SECONDARY_LOAD_SYM opt_use_partition {
            $$= NEW_PTN PT_alter_table_secondary_load(@$, $2);
          }
|SECONDARY_UNLOAD_SYM opt_use_partition {
            $$= NEW_PTN PT_alter_table_secondary_unload(@$, $2);
          }
;

opt_with_validation:
%empty { $$= Alter_info::ALTER_VALIDATION_DEFAULT; }
|with_validation 
;

with_validation:
WITH VALIDATION_SYM {
            $$= Alter_info::ALTER_WITH_VALIDATION;
          }
|WITHOUT_SYM VALIDATION_SYM {
            $$= Alter_info::ALTER_WITHOUT_VALIDATION;
          }
;

all_or_alt_part_name_list:
ALL { $$= nullptr; }
|ident_string_list 
;

alter_list:
alter_list_item {
            $$.flags.init();
            $$.actions= NEW_PTN Mem_root_array<PT_ddl_table_option *>(YYMEM_ROOT);
            if ($$.actions == nullptr || $$.actions->push_back($1))
              MYSQL_YYABORT; 
          }
|alter_list ',' alter_list_item {
            if ($$.actions->push_back($3))
              MYSQL_YYABORT; 
          }
|alter_list ',' alter_commands_modifier {
            $$.flags.merge($3);
          }
|create_table_options_space_separated {
            $$.flags.init();
            $$.actions= $1;
          }
|alter_list ',' create_table_options_space_separated {
            for (auto *option : *$3)
            {
              if ($1.actions->push_back(option))
                MYSQL_YYABORT; 
            }
          }
;

alter_commands_modifier_list:
alter_commands_modifier 
|alter_commands_modifier_list ',' alter_commands_modifier {
            $$= $1;
            $$.merge($3);
          }
;

alter_list_item:
ADD opt_column ident field_def opt_references opt_place {
            $$= NEW_PTN PT_alter_table_add_column(@$, $3, $4, $5, $6);
          }
|ADD opt_column '(' table_element_list ')' {
            $$= NEW_PTN PT_alter_table_add_columns(@$, $4);
          }
|ADD table_constraint_def {
            $$= NEW_PTN PT_alter_table_add_constraint(@$, $2);
          }
|CHANGE opt_column ident ident field_def opt_place {
            $$= NEW_PTN PT_alter_table_change_column(@$, $3, $4, $5, $6);
          }
|MODIFY_SYM opt_column ident field_def opt_place {
            $$= NEW_PTN PT_alter_table_change_column(@$, $3, $4, $5);
          }
|DROP opt_column ident opt_restrict {
            
            $$= NEW_PTN PT_alter_table_drop_column(@$, $3.str);
          }
|DROP FOREIGN KEY_SYM ident {
            $$= NEW_PTN PT_alter_table_drop_foreign_key(@$, $4.str);
          }
|DROP PRIMARY_SYM KEY_SYM {
            $$= NEW_PTN PT_alter_table_drop_key(@$, primary_key_name);
          }
|DROP key_or_index ident {
            $$= NEW_PTN PT_alter_table_drop_key(@$, $3.str);
          }
|DROP CHECK_SYM ident {
            $$= NEW_PTN PT_alter_table_drop_check_constraint(@$, $3.str);
          }
|DROP CONSTRAINT ident {
            $$= NEW_PTN PT_alter_table_drop_constraint(@$, $3.str);
          }
|DISABLE_SYM KEYS {
            $$= NEW_PTN PT_alter_table_enable_keys(@$, false);
          }
|ENABLE_SYM KEYS {
            $$= NEW_PTN PT_alter_table_enable_keys(@$, true);
          }
|ALTER opt_column ident SET_SYM DEFAULT_SYM signed_literal_or_null {
            $$= NEW_PTN PT_alter_table_set_default(@$, $3.str, $6);
          }
|ALTER opt_column ident SET_SYM DEFAULT_SYM '(' expr ')' {
            $$= NEW_PTN PT_alter_table_set_default(@$, $3.str, $7);
          }
|ALTER opt_column ident DROP DEFAULT_SYM {
            $$= NEW_PTN PT_alter_table_set_default(@$, $3.str, nullptr);
          }
|ALTER opt_column ident SET_SYM visibility {
            $$= NEW_PTN PT_alter_table_column_visibility(@$, $3.str, $5);
          }
|ALTER INDEX_SYM ident visibility {
            $$= NEW_PTN PT_alter_table_index_visible(@$, $3.str, $4);
          }
|ALTER CHECK_SYM ident constraint_enforcement {
            $$ = NEW_PTN PT_alter_table_enforce_check_constraint(@$, $3.str, $4);
          }
|ALTER CONSTRAINT ident constraint_enforcement {
            $$ = NEW_PTN PT_alter_table_enforce_constraint(@$, $3.str, $4);
          }
|RENAME opt_to table_ident {
            $$= NEW_PTN PT_alter_table_rename(@$, $3);
          }
|RENAME key_or_index ident TO_SYM ident {
            $$= NEW_PTN PT_alter_table_rename_key(@$, $3.str, $5.str);
          }
|RENAME COLUMN_SYM ident TO_SYM ident {
            $$= NEW_PTN PT_alter_table_rename_column(@$, $3.str, $5.str);
          }
|CONVERT_SYM TO_SYM character_set charset_name opt_collate {
            $$= NEW_PTN PT_alter_table_convert_to_charset(@$, $4, $5);
          }
|CONVERT_SYM TO_SYM character_set DEFAULT_SYM opt_collate {
            $$ = NEW_PTN PT_alter_table_convert_to_charset(
                @$,
                YYTHD->variables.collation_database,
                $5 ? $5 : YYTHD->variables.collation_database);
          }
|FORCE_SYM {
            $$= NEW_PTN PT_alter_table_force(@$);
          }
|ORDER_SYM BY alter_order_list {
            $$= NEW_PTN PT_alter_table_order(@$, $3);
          }
;

alter_commands_modifier:
alter_algorithm_option {
            $$.init();
            $$.algo.set($1);
          }
|alter_lock_option {
            $$.init();
            $$.lock.set($1);
          }
|with_validation {
            $$.init();
            $$.validation.set($1);
          }
;

opt_index_lock_and_algorithm:
%empty { $$.init(); }
|alter_lock_option {
            $$.init();
            $$.lock.set($1);
          }
|alter_algorithm_option {
            $$.init();
            $$.algo.set($1);
          }
|alter_lock_option alter_algorithm_option {
            $$.init();
            $$.lock.set($1);
            $$.algo.set($2);
          }
|alter_algorithm_option alter_lock_option {
            $$.init();
            $$.algo.set($1);
            $$.lock.set($2);
          }
;

alter_algorithm_option:
ALGORITHM_SYM opt_equal alter_algorithm_option_value { $$= $3; }
;

alter_algorithm_option_value:
DEFAULT_SYM {
            $$= Alter_info::ALTER_TABLE_ALGORITHM_DEFAULT;
          }
|ident {
            if (is_identifier($1, "INPLACE"))
              $$= Alter_info::ALTER_TABLE_ALGORITHM_INPLACE;
            else if (is_identifier($1, "INSTANT"))
              $$= Alter_info::ALTER_TABLE_ALGORITHM_INSTANT;
            else if (is_identifier($1, "COPY"))
              $$= Alter_info::ALTER_TABLE_ALGORITHM_COPY;
            else
            {
              my_error(ER_UNKNOWN_ALTER_ALGORITHM, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
          }
;

alter_lock_option:
LOCK_SYM opt_equal alter_lock_option_value { $$= $3; }
;

alter_lock_option_value:
DEFAULT_SYM {
            $$= Alter_info::ALTER_TABLE_LOCK_DEFAULT;
          }
|ident {
            if (is_identifier($1, "NONE"))
              $$= Alter_info::ALTER_TABLE_LOCK_NONE;
            else if (is_identifier($1, "SHARED"))
              $$= Alter_info::ALTER_TABLE_LOCK_SHARED;
            else if (is_identifier($1, "EXCLUSIVE"))
              $$= Alter_info::ALTER_TABLE_LOCK_EXCLUSIVE;
            else
            {
              my_error(ER_UNKNOWN_ALTER_LOCK, MYF(0), $1.str);
              MYSQL_YYABORT;
            }
          }
;

opt_column:
%empty 
|COLUMN_SYM 
;

opt_ignore:
%empty { $$= false; }
|IGNORE_SYM { $$= true; }
;

opt_restrict:
%empty { $$= DROP_DEFAULT; }
|RESTRICT { $$= DROP_RESTRICT; }
|CASCADE { $$= DROP_CASCADE; }
;

opt_place:
%empty { $$= nullptr; }
|AFTER_SYM ident { $$= $2.str; }
|FIRST_SYM { $$= first_keyword; }
;

opt_to:
%empty {}
|TO_SYM {}
|EQ {}
|AS {}
;

group_replication:
group_replication_start opt_group_replication_start_options 
|STOP_SYM GROUP_REPLICATION {
            LEX *lex = Lex;
            lex->sql_command = SQLCOM_STOP_GROUP_REPLICATION;
          }
;

group_replication_start:
START_SYM GROUP_REPLICATION {
            LEX *lex = Lex;
            lex->replica_connection.reset();
            lex->sql_command = SQLCOM_START_GROUP_REPLICATION;
          }
;

opt_group_replication_start_options:
%empty 
|group_replication_start_options 
;

group_replication_start_options:
group_replication_start_option 
|group_replication_start_options ',' group_replication_start_option 
;

group_replication_start_option:
group_replication_user 
|group_replication_password 
|group_replication_plugin_auth 
;

group_replication_user:
USER EQ TEXT_STRING_sys_nonewline {
            Lex->replica_connection.user = $3.str;
            if ($3.length == 0)
            {
              my_error(ER_GROUP_REPLICATION_USER_EMPTY_MSG, MYF(0));
              MYSQL_YYABORT;
            }
          }
;

group_replication_password:
PASSWORD EQ TEXT_STRING_sys_nonewline {
            Lex->replica_connection.password = $3.str;
            Lex->contains_plaintext_password = true;
            if ($3.length > 32)
            {
              my_error(ER_GROUP_REPLICATION_PASSWORD_LENGTH, MYF(0));
              MYSQL_YYABORT;
            }
          }
;

group_replication_plugin_auth:
DEFAULT_AUTH_SYM EQ TEXT_STRING_sys_nonewline {
            Lex->replica_connection.plugin_auth= $3.str;
          }
;

stop_replica_stmt:
STOP_SYM REPLICA_SYM opt_replica_thread_option_list opt_channel {
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_REPLICA_STOP;
            lex->type = 0;
            lex->replica_thd_opt= $3;
            if (lex->set_channel_name($4))
              MYSQL_YYABORT;  
          }
;

start_replica_stmt:
START_SYM REPLICA_SYM opt_replica_thread_option_list {
            LEX *lex=Lex;
            
            lex->replica_connection.reset();
            lex->sql_command = SQLCOM_REPLICA_START;
            lex->type = 0;
            
            lex->mi.set_unspecified();
            lex->replica_thd_opt= $3;
          }opt_replica_until opt_user_option opt_password_option opt_default_auth_option opt_plugin_dir_option {
            
            if ((Lex->replica_thd_opt & REPLICA_SQL) == REPLICA_SQL &&
                (Lex->replica_thd_opt & REPLICA_IO) != REPLICA_IO &&
                (Lex->replica_connection.user ||
                 Lex->replica_connection.password ||
                 Lex->replica_connection.plugin_auth ||
                 Lex->replica_connection.plugin_dir))
            {
              my_error(ER_SQLTHREAD_WITH_SECURE_REPLICA, MYF(0));
              MYSQL_YYABORT;
            }
          }opt_channel {
            if (Lex->set_channel_name($11))
              MYSQL_YYABORT;  
          }
;

start:
START_SYM TRANSACTION_SYM opt_start_transaction_option_list {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_BEGIN;
            
            if (($3 & MYSQL_START_TRANS_OPT_READ_WRITE) &&
                ($3 & MYSQL_START_TRANS_OPT_READ_ONLY))
            {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
            lex->start_transaction_opt= $3;
          }
;

opt_start_transaction_option_list:
%empty {
            $$= 0;
          }
|start_transaction_option_list {
            $$= $1;
          }
;

start_transaction_option_list:
start_transaction_option {
            $$= $1;
          }
|start_transaction_option_list ',' start_transaction_option {
            $$= $1 | $3;
          }
;

start_transaction_option:
WITH CONSISTENT_SYM SNAPSHOT_SYM {
            $$= MYSQL_START_TRANS_OPT_WITH_CONS_SNAPSHOT;
          }
|READ_SYM ONLY_SYM {
            $$= MYSQL_START_TRANS_OPT_READ_ONLY;
          }
|READ_SYM WRITE_SYM {
            $$= MYSQL_START_TRANS_OPT_READ_WRITE;
          }
;

opt_user_option:
%empty {}
|USER EQ TEXT_STRING_sys {
            Lex->replica_connection.user= $3.str;
          }
;

opt_password_option:
%empty {}
|PASSWORD EQ TEXT_STRING_sys {
            Lex->replica_connection.password= $3.str;
            Lex->contains_plaintext_password= true;
          }

opt_default_auth_option:
%empty {}
|DEFAULT_AUTH_SYM EQ TEXT_STRING_sys {
            Lex->replica_connection.plugin_auth= $3.str;
          }
;

opt_plugin_dir_option:
%empty {}
|PLUGIN_DIR_SYM EQ TEXT_STRING_sys {
            Lex->replica_connection.plugin_dir= $3.str;
          }
;

opt_replica_thread_option_list:
%empty {
            $$= 0;
          }
|replica_thread_option_list {
            $$= $1;
          }
;

replica_thread_option_list:
replica_thread_option {
            $$= $1;
          }
|replica_thread_option_list ',' replica_thread_option {
            $$= $1 | $3;
          }
;

replica_thread_option:
SQL_THREAD {
            $$= REPLICA_SQL;
          }
|RELAY_THREAD {
            $$= REPLICA_IO;
          }
;

opt_replica_until:
%empty {
            LEX *lex= Lex;
            lex->mi.replica_until= false;
          }
|UNTIL_SYM replica_until {
            LEX *lex=Lex;
            if (((lex->mi.log_file_name || lex->mi.pos) &&
                lex->mi.gtid) ||
               ((lex->mi.relay_log_name || lex->mi.relay_log_pos) &&
                lex->mi.gtid) ||
                !((lex->mi.log_file_name && lex->mi.pos) ||
                  (lex->mi.relay_log_name && lex->mi.relay_log_pos) ||
                  lex->mi.gtid ||
                  lex->mi.until_after_gaps) ||
                
                
                ((lex->mi.log_file_name || lex->mi.pos || lex->mi.relay_log_name
                  || lex->mi.relay_log_pos || lex->mi.gtid)
                 && lex->mi.until_after_gaps))
            {
               my_error(ER_BAD_REPLICA_UNTIL_COND, MYF(0));
               MYSQL_YYABORT;
            }
            lex->mi.replica_until= true;
          }
;

replica_until:
source_file_def 
|replica_until ',' source_file_def 
|SQL_BEFORE_GTIDS EQ TEXT_STRING_sys {
            Lex->mi.gtid= $3.str;
            Lex->mi.gtid_until_condition= LEX_SOURCE_INFO::UNTIL_SQL_BEFORE_GTIDS;
          }
|SQL_AFTER_GTIDS EQ TEXT_STRING_sys {
            Lex->mi.gtid= $3.str;
            Lex->mi.gtid_until_condition= LEX_SOURCE_INFO::UNTIL_SQL_AFTER_GTIDS;
          }
|SQL_AFTER_MTS_GAPS {
            Lex->mi.until_after_gaps= true;
          }
;

checksum:
CHECKSUM_SYM table_or_tables table_list opt_checksum_type {
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_CHECKSUM;
            
            YYPS->m_lock_type= TL_UNLOCK;
            if (Select->add_tables(YYTHD, $3, TL_OPTION_UPDATING,
                                   YYPS->m_lock_type, YYPS->m_mdl_type))
              MYSQL_YYABORT;
            Lex->check_opt.flags= $4;
          }
;

opt_checksum_type:
%empty { $$= 0; }
|QUICK { $$= T_QUICK; }
|EXTENDED_SYM { $$= T_EXTEND; }
;

repair_table_stmt:
REPAIR opt_no_write_to_binlog table_or_tables table_list opt_mi_repair_types {
            $$= NEW_PTN PT_repair_table_stmt(@$, YYMEM_ROOT, $2, $4,
                                             $5.flags, $5.sql_flags);
          }
;

opt_mi_repair_types:
%empty { $$.flags = T_MEDIUM; $$.sql_flags= 0; }
|mi_repair_types 
;

mi_repair_types:
mi_repair_type 
|mi_repair_types mi_repair_type {
            $$.flags= $1.flags | $2.flags;
            $$.sql_flags= $1.sql_flags | $2.sql_flags;
          }
;

mi_repair_type:
QUICK { $$.flags= T_QUICK;  $$.sql_flags= 0; }
|EXTENDED_SYM { $$.flags= T_EXTEND; $$.sql_flags= 0; }
|USE_FRM { $$.flags= 0;        $$.sql_flags= TT_USEFRM; }
;

analyze_table_stmt:
ANALYZE_SYM opt_no_write_to_binlog table_or_tables table_list opt_histogram {
            if ($5.param) {
              $$= NEW_PTN PT_analyze_table_stmt(@$, YYMEM_ROOT, $2, $4,
                                                $5.command, $5.param->num_buckets,
                                                $5.columns, $5.param->data, $5.param->auto_update);
            } else {
              $$= NEW_PTN PT_analyze_table_stmt(@$, YYMEM_ROOT, $2, $4,
                                                $5.command, 0,
                                                $5.columns, {nullptr, 0}, false);
            }
          }
;

opt_histogram_auto_update:
%empty { $$= false; }
|MANUAL_SYM UPDATE_SYM { $$= false; }
|AUTO_SYM UPDATE_SYM { $$= true; }
;

opt_histogram_num_buckets:
%empty {
            $$= DEFAULT_NUMBER_OF_HISTOGRAM_BUCKETS;
          }
|WITH NUM BUCKETS_SYM {
            int error;
            longlong num= my_strtoll10($2.str, nullptr, &error);
            MYSQL_YYABORT_UNLESS(error <= 0);

            if (num < 1 || num > MAX_NUMBER_OF_HISTOGRAM_BUCKETS)
            {
              my_error(ER_DATA_OUT_OF_RANGE, MYF(0), "Number of buckets",
                       "ANALYZE TABLE");
              MYSQL_YYABORT;
            }
            $$= num;
          }
;

opt_histogram_update_param:
opt_histogram_num_buckets opt_histogram_auto_update {
            $$.num_buckets= $1;
            $$.auto_update= $2;
            $$.data= { nullptr, 0 };
          }
|USING DATA_SYM TEXT_STRING_literal {
            $$.num_buckets= 0;
            $$.auto_update= false;
            $$.data= $3;
          }
;

opt_histogram:
%empty {
            $$.command= Sql_cmd_analyze_table::Histogram_command::NONE;
            $$.columns= nullptr;
            $$.param= nullptr;
          }
|UPDATE_SYM HISTOGRAM_SYM ON_SYM ident_string_list opt_histogram_update_param {
            $$.command=
              Sql_cmd_analyze_table::Histogram_command::UPDATE_HISTOGRAM;
            $$.columns= $4;
            $$.param= NEW_PTN YYSTYPE::Histogram_param($5);
            if ($$.param == nullptr)
              MYSQL_YYABORT; 
          }
|DROP HISTOGRAM_SYM ON_SYM ident_string_list {
            $$.command=
              Sql_cmd_analyze_table::Histogram_command::DROP_HISTOGRAM;
            $$.columns= $4;
            $$.param = nullptr;
          }
;

binlog_base64_event:
BINLOG_SYM TEXT_STRING_sys {
            Lex->sql_command = SQLCOM_BINLOG_BASE64_EVENT;
            Lex->binlog_stmt_arg= $2;
          }
;

check_table_stmt:
CHECK_SYM table_or_tables table_list opt_mi_check_types {
            $$= NEW_PTN PT_check_table_stmt(@$, YYMEM_ROOT, $3,
                                            $4.flags, $4.sql_flags);
          }
;

opt_mi_check_types:
%empty { $$.flags = T_MEDIUM; $$.sql_flags= 0; }
|mi_check_types 
;

mi_check_types:
mi_check_type 
|mi_check_type mi_check_types {
            $$.flags= $1.flags | $2.flags;
            $$.sql_flags= $1.sql_flags | $2.sql_flags;
          }
;

mi_check_type:
QUICK { $$.flags= T_QUICK;              $$.sql_flags= 0; }
|FAST_SYM { $$.flags= T_FAST;               $$.sql_flags= 0; }
|MEDIUM_SYM { $$.flags= T_MEDIUM;             $$.sql_flags= 0; }
|EXTENDED_SYM { $$.flags= T_EXTEND;             $$.sql_flags= 0; }
|CHANGED { $$.flags= T_CHECK_ONLY_CHANGED; $$.sql_flags= 0; }
|FOR_SYM UPGRADE_SYM { $$.flags= 0;                    $$.sql_flags= TT_FOR_UPGRADE; }
;

optimize_table_stmt:
OPTIMIZE opt_no_write_to_binlog table_or_tables table_list {
            $$= NEW_PTN PT_optimize_table_stmt(@$, YYMEM_ROOT, $2, $4);
          }
;

opt_no_write_to_binlog:
%empty { $$= 0; }
|NO_WRITE_TO_BINLOG { $$= 1; }
|LOCAL_SYM { $$= 1; }
;

rename:
RENAME table_or_tables {
            Lex->sql_command= SQLCOM_RENAME_TABLE;
          }table_to_table_list {}
|RENAME USER rename_list {
            Lex->sql_command = SQLCOM_RENAME_USER;
          }
;

rename_list:
user TO_SYM user {
            if (Lex->users_list.push_back($1) || Lex->users_list.push_back($3))
              MYSQL_YYABORT;
          }
|rename_list ',' user TO_SYM user {
            if (Lex->users_list.push_back($3) || Lex->users_list.push_back($5))
              MYSQL_YYABORT;
          }
;

table_to_table_list:
table_to_table 
|table_to_table_list ',' table_to_table 
;

table_to_table:
table_ident TO_SYM table_ident {
            LEX *lex=Lex;
            Query_block *sl= Select;
            if (!sl->add_table_to_list(lex->thd, $1,nullptr,TL_OPTION_UPDATING,
                                       TL_IGNORE, MDL_EXCLUSIVE) ||
                !sl->add_table_to_list(lex->thd, $3,nullptr,TL_OPTION_UPDATING,
                                       TL_IGNORE, MDL_EXCLUSIVE))
              MYSQL_YYABORT;
          }
;

keycache_stmt:
CACHE_SYM INDEX_SYM keycache_list IN_SYM key_cache_name {
            $$= NEW_PTN PT_cache_index_stmt(@$, YYMEM_ROOT, $3, $5);
          }
|CACHE_SYM INDEX_SYM table_ident adm_partition opt_cache_key_list IN_SYM key_cache_name {
            $$= NEW_PTN PT_cache_index_partitions_stmt(@$, YYMEM_ROOT,
                                                       $3, $4, $5, $7);
          }
;

keycache_list:
assign_to_keycache {
            $$= NEW_PTN Mem_root_array<PT_assign_to_keycache *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|keycache_list ',' assign_to_keycache {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

assign_to_keycache:
table_ident opt_cache_key_list {
            $$= NEW_PTN PT_assign_to_keycache(@$, $1, $2);
          }
;

key_cache_name:
ident { $$= to_lex_cstring($1); }
|DEFAULT_SYM { $$ = default_key_cache_base; }
;

preload_stmt:
LOAD INDEX_SYM INTO CACHE_SYM table_ident adm_partition opt_cache_key_list opt_ignore_leaves {
            $$= NEW_PTN PT_load_index_partitions_stmt(@$, YYMEM_ROOT, $5,$6, $7, $8);
          }
|LOAD INDEX_SYM INTO CACHE_SYM preload_list {
            $$= NEW_PTN PT_load_index_stmt(@$, YYMEM_ROOT, $5);
          }
;

preload_list:
preload_keys {
            $$= NEW_PTN Mem_root_array<PT_preload_keys *>(YYMEM_ROOT);
            if ($$->push_back($1))
              MYSQL_YYABORT; 
          }
|preload_list ',' preload_keys {
            $$= $1;
            if ($$ == nullptr || $$->push_back($3))
              MYSQL_YYABORT; 
          }
;

preload_keys:
table_ident opt_cache_key_list opt_ignore_leaves {
            $$= NEW_PTN PT_preload_keys(@$, $1, $2, $3);
          }
;

adm_partition:
PARTITION_SYM '(' all_or_alt_part_name_list ')' {
            $$= NEW_PTN PT_adm_partition(@$, $3);
          }
;

opt_cache_key_list:
%empty { $$= nullptr; }
|key_or_index '(' opt_key_usage_list ')' {
            init_index_hints($3, INDEX_HINT_USE, INDEX_HINT_MASK_ALL);
            $$= $3;
          }
;

opt_ignore_leaves:
%empty { $$= false; }
|IGNORE_SYM LEAVES { $$= true; }
;

select_stmt:
query_expression {
            $$ = NEW_PTN PT_select_stmt(@$, $1);
          }
|query_expression locking_clause_list {
            $$ = NEW_PTN PT_select_stmt(@$, NEW_PTN PT_locking(@$, $1, $2),
                                        nullptr, true);
          }
|select_stmt_with_into 
;

select_stmt_with_into:
'(' select_stmt_with_into ')' {
            $$ = $2;
            if ($$ != nullptr) $$->m_pos = @$;
          }
|query_expression into_clause {
            $$ = NEW_PTN PT_select_stmt(@$, $1, $2);
          }
|query_expression into_clause locking_clause_list {
            $$ = NEW_PTN PT_select_stmt(@$, NEW_PTN PT_locking(@$, $1, $3), $2, true);
          }
|query_expression locking_clause_list into_clause {
            $$ = NEW_PTN PT_select_stmt(@$, NEW_PTN PT_locking(@$, $1, $2), $3);
          }
;

query_expression:
query_expression_body opt_order_clause opt_limit_clause {
            $$ = NEW_PTN PT_query_expression(@$, $1.body, $2, $3);
          }
|with_clause query_expression_body opt_order_clause opt_limit_clause {
            $$= NEW_PTN PT_query_expression(@$, $1, $2.body, $3, $4);
          }
;

query_expression_body:
query_primary {
            $$ = {$1, false};
          }
|query_expression_parens %prec PREFER_PARENTHESES {
            $$ = {$1, true};
          }
|query_expression_body UNION_SYM union_option query_expression_body {
            $$ = {NEW_PTN PT_union(@$, $1.body, $3, $4.body, $4.is_parenthesized),
                  false};
          }
|query_expression_body EXCEPT_SYM union_option query_expression_body {
            $$ = {NEW_PTN PT_except(@$, $1.body, $3, $4.body, $4.is_parenthesized),
                  false};
          }
|query_expression_body INTERSECT_SYM union_option query_expression_body {
            $$ = {NEW_PTN PT_intersect(@$, $1.body, $3, $4.body, $4.is_parenthesized),
                  false};
          }
;

query_expression_parens:
'(' query_expression_parens ')' { $$ = $2;
            if ($$ != nullptr) $$->m_pos = @$;
          }
|'(' query_expression_with_opt_locking_clauses ')' { $$ = $2;
            if ($$ != nullptr) $$->m_pos = @$;
          }
;

query_primary:
query_specification {
            
            $$= $1;
          }
|table_value_constructor {
            $$= NEW_PTN PT_table_value_constructor(@$, $1);
          }
|explicit_table {
            
            auto item_list= NEW_PTN PT_select_item_list(POS());
            auto asterisk= NEW_PTN Item_asterisk(POS(), nullptr, nullptr);
            if (item_list == nullptr || asterisk == nullptr ||
                item_list->push_back(asterisk))
              MYSQL_YYABORT;
            $$= NEW_PTN PT_explicit_table(@$, {}, item_list, $1);
          }
;

query_specification:
SELECT_SYM select_options select_item_list into_clause opt_from_clause opt_where_clause opt_group_clause opt_having_clause opt_window_clause opt_qualify_clause {
            $$= NEW_PTN PT_query_specification(
                                      @$,
                                      $1,  
                                      $2,  
                                      $3,  
                                      $4,  
                                      $5,  
                                      $6,  
                                      $7,  
                                      $8,  
                                      $9,  
                                      $10, 
                                      @5.raw.is_empty()); 
          }
|SELECT_SYM select_options select_item_list opt_from_clause opt_where_clause opt_group_clause opt_having_clause opt_window_clause opt_qualify_clause {
            $$= NEW_PTN PT_query_specification(
                                      @$,
                                      $1,  
                                      $2,  
                                      $3,  
                                      nullptr,
                                      $4,  
                                      $5,  
                                      $6,  
                                      $7,  
                                      $8,  
                                      $9,  
                                      @4.raw.is_empty()); 
          }
;

opt_from_clause:
%empty %prec EMPTY_FROM_CLAUSE { $$.init(YYMEM_ROOT); }
|from_clause 
;

from_clause:
FROM from_tables { $$= $2; }
;

from_tables:
DUAL_SYM { $$.init(YYMEM_ROOT); }
|table_reference_list 
;

table_reference_list:
table_reference {
            $$.init(YYMEM_ROOT);
            if ($$.push_back($1))
              MYSQL_YYABORT; 
          }
|table_reference_list ',' table_reference {
            $$= $1;
            if ($$.push_back($3))
              MYSQL_YYABORT; 
          }
;

table_value_constructor:
VALUES values_row_list {
            $$= $2;
          }
;

explicit_table:
TABLE_SYM table_ident {
            $$.init(YYMEM_ROOT);
            auto table= NEW_PTN
                PT_table_factor_table_ident(@$, $2, nullptr, NULL_CSTR, nullptr, nullptr);
            if ($$.push_back(table))
              MYSQL_YYABORT; 
          }
;

select_options:
%empty {
            $$.query_spec_options= 0;
          }
|select_option_list 
;

select_option_list:
select_option_list select_option {
            if ($$.merge($1, $2))
              MYSQL_YYABORT;
          }
|select_option 
;

select_option:
query_spec_option {
            $$.query_spec_options= $1;
          }
|SQL_NO_CACHE_SYM {
            push_deprecated_warn_no_replacement(YYTHD, "SQL_NO_CACHE");
            
            $$.query_spec_options= 0;
          }
;

locking_clause_list:
locking_clause_list locking_clause {
            $$= $1;
            if ($$->push_back($2))
              MYSQL_YYABORT; 
          }
|locking_clause {
            $$= NEW_PTN PT_locking_clause_list(@$, YYTHD->mem_root);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
;

locking_clause:
FOR_SYM lock_strength opt_locked_row_action {
            $$= NEW_PTN PT_query_block_locking_clause(@$, $2, $3);
          }
|FOR_SYM lock_strength table_locking_list opt_locked_row_action {
            $$= NEW_PTN PT_table_locking_clause(@$, $2, $3, $4);
          }
|LOCK_SYM IN_SYM SHARE_SYM MODE_SYM {
            $$= NEW_PTN PT_query_block_locking_clause(@$, Lock_strength::SHARE);
          }
;

lock_strength:
UPDATE_SYM { $$= Lock_strength::UPDATE; }
|SHARE_SYM { $$= Lock_strength::SHARE; }
;

table_locking_list:
OF_SYM table_alias_ref_list { $$= $2; }
;

opt_locked_row_action:
%empty { $$= Locked_row_action::WAIT; }
|locked_row_action 
;

locked_row_action:
SKIP_SYM LOCKED_SYM { $$= Locked_row_action::SKIP; }
|NOWAIT_SYM { $$= Locked_row_action::NOWAIT; }
;

select_item_list:
select_item_list ',' select_item {
            if ($1 == nullptr || $1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
            $$->m_pos = @$;
          }
|select_item {
            $$= NEW_PTN PT_select_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|'*' {
            Item *item = NEW_PTN Item_asterisk(@$, nullptr, nullptr);
            $$ = NEW_PTN PT_select_item_list(@$);
            if ($$ == nullptr || item == nullptr || $$->push_back(item))
              MYSQL_YYABORT;
          }
;

select_item:
table_wild { $$= $1; }
|expr select_alias {
            $$= NEW_PTN PTI_expr_with_alias(@$, $1, @1.cpp, to_lex_cstring($2));
          }
;

select_alias:
%empty { $$=null_lex_str;}
|AS ident { $$=$2; }
|AS TEXT_STRING_validated { $$=$2; }
|ident { $$=$1; }
|TEXT_STRING_validated { $$=$1; }
;

optional_braces:
%empty {}
|'(' ')' {}
;

expr:
expr or expr %prec OR_SYM {
            $$= flatten_associative_operator<Item_cond_or,
                                             Item_func::COND_OR_FUNC>(
                                                 YYMEM_ROOT, @$, $1, $3);
            if ($$ != nullptr) $$->m_pos = @$;
          }
|expr XOR expr %prec XOR {
            
            $$ = NEW_PTN Item_func_xor(@$, $1, $3);
          }
|expr and expr %prec AND_SYM {
            $$= flatten_associative_operator<Item_cond_and,
                                             Item_func::COND_AND_FUNC>(
                                                 YYMEM_ROOT, @$, $1, $3);
            if ($$ != nullptr) $$->m_pos = @$;
          }
|NOT_SYM expr %prec NOT_SYM {
            $$= NEW_PTN PTI_truth_transform(@$, $2, Item::BOOL_NEGATED);
          }
|bool_pri IS TRUE_SYM %prec IS {
            $$= NEW_PTN PTI_truth_transform(@$, $1, Item::BOOL_IS_TRUE);
          }
|bool_pri IS not TRUE_SYM %prec IS {
            $$= NEW_PTN PTI_truth_transform(@$, $1, Item::BOOL_NOT_TRUE);
          }
|bool_pri IS FALSE_SYM %prec IS {
            $$= NEW_PTN PTI_truth_transform(@$, $1, Item::BOOL_IS_FALSE);
          }
|bool_pri IS not FALSE_SYM %prec IS {
            $$= NEW_PTN PTI_truth_transform(@$, $1, Item::BOOL_NOT_FALSE);
          }
|bool_pri IS UNKNOWN_SYM %prec IS {
            $$= NEW_PTN Item_func_isnull(@$, $1);
          }
|bool_pri IS not UNKNOWN_SYM %prec IS {
            $$= NEW_PTN Item_func_isnotnull(@$, $1);
          }
|bool_pri %prec SET_VAR 
;

bool_pri:
bool_pri IS NULL_SYM %prec IS {
            $$= NEW_PTN Item_func_isnull(@$, $1);
          }
|bool_pri IS not NULL_SYM %prec IS {
            $$= NEW_PTN Item_func_isnotnull(@$, $1);
          }
|bool_pri comp_op predicate {
            $$= NEW_PTN PTI_comp_op(@$, $1, $2, $3);
          }
|bool_pri comp_op all_or_any table_subquery %prec EQ {
            if ($2 == &comp_equal_creator)
              
              YYTHD->syntax_error_at(@2);
            $$= NEW_PTN PTI_comp_op_all(@$, $1, $2, $3, $4);
          }
|predicate %prec SET_VAR 
;

predicate:
bit_expr IN_SYM table_subquery {
            $$= NEW_PTN Item_in_subselect(@$, $1, $3);
          }
|bit_expr not IN_SYM table_subquery {
            Item *item= NEW_PTN Item_in_subselect(@$, $1, $4);
            $$= NEW_PTN PTI_truth_transform(@$, item, Item::BOOL_NEGATED);
          }
|bit_expr IN_SYM '(' expr ')' {
            $$= NEW_PTN PTI_handle_sql2003_note184_exception(@$, $1, false, $4);
          }
|bit_expr IN_SYM '(' expr ',' expr_list ')' {
            if ($6 == nullptr || $6->push_front($4) || $6->push_front($1))
              MYSQL_YYABORT;

            $$= NEW_PTN Item_func_in(@$, $6, false);
          }
|bit_expr not IN_SYM '(' expr ')' {
            $$= NEW_PTN PTI_handle_sql2003_note184_exception(@$, $1, true, $5);
          }
|bit_expr not IN_SYM '(' expr ',' expr_list ')' {
            if ($7 == nullptr)
              MYSQL_YYABORT;
            $7->push_front($5);
            $7->value.push_front($1);

            $$= NEW_PTN Item_func_in(@$, $7, true);
          }
|bit_expr MEMBER_SYM opt_of '(' simple_expr ')' {
            $$= NEW_PTN Item_func_member_of(@$, $1, $5);
          }
|bit_expr BETWEEN_SYM bit_expr AND_SYM predicate {
            $$= NEW_PTN Item_func_between(@$, $1, $3, $5, false);
          }
|bit_expr not BETWEEN_SYM bit_expr AND_SYM predicate {
            $$= NEW_PTN Item_func_between(@$, $1, $4, $6, true);
          }
|bit_expr SOUNDS_SYM LIKE bit_expr {
            Item *item1= NEW_PTN Item_func_soundex(@$, $1);
            Item *item4= NEW_PTN Item_func_soundex(@$, $4);
            if ((item1 == nullptr) || (item4 == nullptr))
              MYSQL_YYABORT;
            $$= NEW_PTN Item_func_eq(@$, item1, item4);
          }
|bit_expr LIKE simple_expr {
            $$ = NEW_PTN Item_func_like(@$, $1, $3);
          }
|bit_expr LIKE simple_expr ESCAPE_SYM simple_expr %prec LIKE {
            $$ = NEW_PTN Item_func_like(@$, $1, $3, $5);
          }
|bit_expr not LIKE simple_expr {
            auto item = NEW_PTN Item_func_like(@$, $1, $4);
            $$ = NEW_PTN Item_func_not(@$, item);
          }
|bit_expr not LIKE simple_expr ESCAPE_SYM simple_expr %prec LIKE {
            auto item = NEW_PTN Item_func_like(@$, $1, $4, $6);
            $$ = NEW_PTN Item_func_not(@$, item);
          }
|bit_expr REGEXP bit_expr {
            auto args= NEW_PTN PT_item_list(@$);
            args->push_back($1);
            args->push_back($3);

            $$= NEW_PTN Item_func_regexp_like(@1, args);
          }
|bit_expr not REGEXP bit_expr {
            auto args= NEW_PTN PT_item_list(@$);
            args->push_back($1);
            args->push_back($4);
            Item *item= NEW_PTN Item_func_regexp_like(@$, args);
            $$= NEW_PTN PTI_truth_transform(@$, item, Item::BOOL_NEGATED);
          }
|bit_expr %prec SET_VAR 
;

opt_of:
OF_SYM 
|%empty 
;

bit_expr:
bit_expr '|' bit_expr %prec '|' {
            $$= NEW_PTN Item_func_bit_or(@$, $1, $3);
          }
|bit_expr '&' bit_expr %prec '&' {
            $$= NEW_PTN Item_func_bit_and(@$, $1, $3);
          }
|bit_expr SHIFT_LEFT bit_expr %prec SHIFT_LEFT {
            $$= NEW_PTN Item_func_shift_left(@$, $1, $3);
          }
|bit_expr SHIFT_RIGHT bit_expr %prec SHIFT_RIGHT {
            $$= NEW_PTN Item_func_shift_right(@$, $1, $3);
          }
|bit_expr '+' bit_expr %prec '+' {
            $$= NEW_PTN Item_func_plus(@$, $1, $3);
          }
|bit_expr '-' bit_expr %prec '-' {
            $$= NEW_PTN Item_func_minus(@$, $1, $3);
          }
|bit_expr '+' INTERVAL_SYM expr interval %prec '+' {
            $$= NEW_PTN Item_date_add_interval(@$, $1, $4, $5, 0);
          }
|bit_expr '-' INTERVAL_SYM expr interval %prec '-' {
            $$= NEW_PTN Item_date_add_interval(@$, $1, $4, $5, 1);
          }
|bit_expr '*' bit_expr %prec '*' {
            $$= NEW_PTN Item_func_mul(@$, $1, $3);
          }
|bit_expr '/' bit_expr %prec '/' {
            $$= NEW_PTN Item_func_div(@$, $1,$3);
          }
|bit_expr '%' bit_expr %prec '%' {
            $$= NEW_PTN Item_func_mod(@$, $1,$3);
          }
|bit_expr DIV_SYM bit_expr %prec DIV_SYM {
            $$= NEW_PTN Item_func_div_int(@$, $1,$3);
          }
|bit_expr MOD_SYM bit_expr %prec MOD_SYM {
            $$= NEW_PTN Item_func_mod(@$, $1, $3);
          }
|bit_expr '^' bit_expr {
            $$= NEW_PTN Item_func_bit_xor(@$, $1, $3);
          }
|simple_expr %prec SET_VAR 
;

or:
OR_SYM 
|OR2_SYM 
;

and:
AND_SYM 
|AND_AND_SYM {
           push_deprecated_warn(YYTHD, "&&", "AND");
         }
;

not:
NOT_SYM 
|NOT2_SYM 
;

not2:
'!' { push_deprecated_warn(YYTHD, "!", "NOT"); }
|NOT2_SYM 
;

comp_op:
EQ { $$ = &comp_eq_creator; }
|EQUAL_SYM { $$ = &comp_equal_creator; }
|GE { $$ = &comp_ge_creator; }
|GT_SYM { $$ = &comp_gt_creator; }
|LE { $$ = &comp_le_creator; }
|LT { $$ = &comp_lt_creator; }
|NE { $$ = &comp_ne_creator; }
;

all_or_any:
ALL { $$ = 1; }
|ANY_SYM { $$ = 0; }
;

simple_expr:
simple_ident 
|function_call_keyword 
|function_call_nonkeyword 
|function_call_generic 
|function_call_conflict 
|simple_expr COLLATE_SYM ident_or_text %prec NEG {
            warn_on_deprecated_user_defined_collation(YYTHD, $3);
            $$= NEW_PTN Item_func_set_collation(@$, $1, $3);
          }
|literal_or_null 
|param_marker { $$= $1; }
|rvalue_system_or_user_variable 
|in_expression_user_variable_assignment 
|set_function_specification 
|window_func_call 
|simple_expr OR_OR_SYM simple_expr {
            $$= NEW_PTN Item_func_concat(@$, $1, $3);
          }
|'+' simple_expr %prec NEG {
            $$= $2; 
            if ($$ != nullptr) $$->m_pos = @$;
          }
|'-' simple_expr %prec NEG {
            $$= NEW_PTN Item_func_neg(@$, $2);
          }
|'~' simple_expr %prec NEG {
            $$= NEW_PTN Item_func_bit_neg(@$, $2);
          }
|not2 simple_expr %prec NEG {
            $$= NEW_PTN PTI_truth_transform(@$, $2, Item::BOOL_NEGATED);
          }
|row_subquery {
            $$= NEW_PTN PTI_singlerow_subselect(@$, $1);
          }
|'(' expr ')' {
            $$= $2;
            if ($$ != nullptr) $$->m_pos = @$;
          }
|'(' expr ',' expr_list ')' {
            $$= NEW_PTN Item_row(@$, $2, $4->value);
          }
|ROW_SYM '(' expr ',' expr_list ')' {
            $$= NEW_PTN Item_row(@$, $3, $5->value);
          }
|EXISTS table_subquery {
            $$= NEW_PTN PTI_exists_subselect(@$, $2);
          }
|'{' ident expr '}' {
            $$= NEW_PTN PTI_odbc_date(@$, $2, $3);
          }
|MATCH ident_list_arg AGAINST '(' bit_expr fulltext_options ')' {
            $$= NEW_PTN Item_func_match(@$, $2, $5, $6);
          }
|BINARY_SYM simple_expr %prec NEG {
            push_deprecated_warn(YYTHD, "BINARY expr", "CAST");
            $$= create_func_cast(YYTHD, @$, $2, ITEM_CAST_CHAR, &my_charset_bin);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|CAST_SYM '(' expr AS cast_type opt_array_cast ')' {
            $$= create_func_cast(YYTHD, @$, $3, $5, $6);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|CAST_SYM '(' expr AT_SYM LOCAL_SYM AS cast_type opt_array_cast ')' {
            my_error(ER_NOT_SUPPORTED_YET, MYF(0), "AT LOCAL");
          }
|CAST_SYM '(' expr AT_SYM TIME_SYM ZONE_SYM opt_interval TEXT_STRING_literal AS DATETIME_SYM type_datetime_precision ')' {
            Cast_type cast_type{ITEM_CAST_DATETIME, nullptr, nullptr, $11};
            auto datetime_factor =
                NEW_PTN Item_func_at_time_zone(@3, $3, $8.str, $7);
            $$ = create_func_cast(YYTHD, @$, datetime_factor, cast_type, false);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|CASE_SYM opt_expr when_list opt_else END {
            $$= NEW_PTN Item_func_case(@$, $3, $2, $4 );
          }
|CONVERT_SYM '(' expr ',' cast_type ')' {
            $$= create_func_cast(YYTHD, @$, $3, $5, false);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|CONVERT_SYM '(' expr USING charset_name ')' {
            $$= NEW_PTN Item_func_conv_charset(@$, $3,$5);
          }
|DEFAULT_SYM '(' simple_ident ')' {
            $$= NEW_PTN Item_default_value(@$, $3);
          }
|VALUES '(' simple_ident_nospvar ')' {
            $$= NEW_PTN Item_insert_value(@$, $3);
          }
|INTERVAL_SYM expr interval '+' expr %prec INTERVAL_SYM {
            $$= NEW_PTN Item_date_add_interval(@$, $5, $2, $3, 0);
          }
|simple_ident JSON_SEPARATOR_SYM TEXT_STRING_literal {
            Item_string *path=
              NEW_PTN Item_string(@3, $3.str, $3.length,
                                  YYTHD->variables.collation_connection);
            $$= NEW_PTN Item_func_json_extract(YYTHD, @$, $1, path);
          }
|simple_ident JSON_UNQUOTED_SEPARATOR_SYM TEXT_STRING_literal {
            Item_string *path=
              NEW_PTN Item_string(@3, $3.str, $3.length,
                                  YYTHD->variables.collation_connection);
            Item *extr= NEW_PTN Item_func_json_extract(YYTHD, @$, $1, path);
            $$= NEW_PTN Item_func_json_unquote(@$, extr);
          }
;

opt_array_cast:
%empty { $$= false; }
|ARRAY_SYM { $$= true; }
;

function_call_keyword:
CHAR_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_char(@$, $3);
          }
|CHAR_SYM '(' expr_list USING charset_name ')' {
            $$= NEW_PTN Item_func_char(@$, $3, $5);
          }
|CURRENT_USER optional_braces {
            $$= NEW_PTN Item_func_current_user(@$);
          }
|DATE_SYM '(' expr ')' {
            $$= NEW_PTN Item_typecast_date(@$, $3);
          }
|DAY_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_dayofmonth(@$, $3);
          }
|HOUR_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_hour(@$, $3);
          }
|INSERT_SYM '(' expr ',' expr ',' expr ',' expr ')' {
            $$= NEW_PTN Item_func_insert(@$, $3, $5, $7, $9);
          }
|INTERVAL_SYM '(' expr ',' expr ')' %prec INTERVAL_SYM {
            $$= NEW_PTN Item_func_interval(@$, YYMEM_ROOT, $3, $5);
          }
|INTERVAL_SYM '(' expr ',' expr ',' expr_list ')' %prec INTERVAL_SYM {
            $$= NEW_PTN Item_func_interval(@$, YYMEM_ROOT, $3, $5, $7);
          }
|JSON_VALUE_SYM '(' simple_expr ',' text_literal opt_returning_type opt_on_empty_or_error ')' {
            $$= create_func_json_value(YYTHD, @3, $3, $5, $6,
                                       $7.empty.type, $7.empty.default_string,
                                       $7.error.type, $7.error.default_string);
          }
|LEFT '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_left(@$, $3, $5);
          }
|MINUTE_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_minute(@$, $3);
          }
|MONTH_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_month(@$, $3);
          }
|RIGHT '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_right(@$, $3, $5);
          }
|SECOND_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_second(@$, $3);
          }
|TIME_SYM '(' expr ')' {
            $$= NEW_PTN Item_typecast_time(@$, $3);
          }
|TIMESTAMP_SYM '(' expr ')' {
            $$= NEW_PTN Item_typecast_datetime(@$, $3);
          }
|TIMESTAMP_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_add_time(@$, $3, $5, 1, 0);
          }
|TRIM '(' expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $3,
                                       Item_func_trim::TRIM_BOTH_DEFAULT);
          }
|TRIM '(' LEADING expr FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $6, $4,
                                       Item_func_trim::TRIM_LEADING);
          }
|TRIM '(' TRAILING expr FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $6, $4,
                                       Item_func_trim::TRIM_TRAILING);
          }
|TRIM '(' BOTH expr FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $6, $4, Item_func_trim::TRIM_BOTH);
          }
|TRIM '(' LEADING FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $5, Item_func_trim::TRIM_LEADING);
          }
|TRIM '(' TRAILING FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $5, Item_func_trim::TRIM_TRAILING);
          }
|TRIM '(' BOTH FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $5, Item_func_trim::TRIM_BOTH);
          }
|TRIM '(' expr FROM expr ')' {
            $$= NEW_PTN Item_func_trim(@$, $5, $3,
                                       Item_func_trim::TRIM_BOTH_DEFAULT);
          }
|USER '(' ')' {
            $$= NEW_PTN Item_func_user(@$);
          }
|YEAR_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_year(@$, $3);
          }
;

function_call_nonkeyword:
ADDDATE_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_date_add_interval(@$, $3, $5, INTERVAL_DAY, 0);
          }
|ADDDATE_SYM '(' expr ',' INTERVAL_SYM expr interval ')' {
            $$= NEW_PTN Item_date_add_interval(@$, $3, $6, $7, 0);
          }
|CURDATE optional_braces {
            $$= NEW_PTN Item_func_curdate_local(@$);
          }
|CURTIME func_datetime_precision {
            $$= NEW_PTN Item_func_curtime_local(@$, static_cast<uint8>($2));
          }
|DATE_ADD_INTERVAL '(' expr ',' INTERVAL_SYM expr interval ')' %prec INTERVAL_SYM {
            $$= NEW_PTN Item_date_add_interval(@$, $3, $6, $7, 0);
          }
|DATE_SUB_INTERVAL '(' expr ',' INTERVAL_SYM expr interval ')' %prec INTERVAL_SYM {
            $$= NEW_PTN Item_date_add_interval(@$, $3, $6, $7, 1);
          }
|EXTRACT_SYM '(' interval FROM expr ')' {
            $$= NEW_PTN Item_extract(@$,  $3, $5);
          }
|GET_FORMAT '(' date_time_type ',' expr ')' {
            $$= NEW_PTN Item_func_get_format(@$, $3, $5);
          }
|LOG_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_log(@$, $3);
          }
|LOG_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_log(@$, $3, $5);
          }
|now {
            $$= NEW_PTN PTI_function_call_nonkeyword_now(@$,
              static_cast<uint8>($1));
          }
|POSITION_SYM '(' bit_expr IN_SYM expr ')' {
            $$= NEW_PTN Item_func_locate(@$, $5,$3);
          }
|SUBDATE_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_date_add_interval(@$, $3, $5, INTERVAL_DAY, 1);
          }
|SUBDATE_SYM '(' expr ',' INTERVAL_SYM expr interval ')' {
            $$= NEW_PTN Item_date_add_interval(@$, $3, $6, $7, 1);
          }
|SUBSTRING '(' expr ',' expr ',' expr ')' {
            $$= NEW_PTN Item_func_substr(@$, $3,$5,$7);
          }
|SUBSTRING '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_substr(@$, $3,$5);
          }
|SUBSTRING '(' expr FROM expr FOR_SYM expr ')' {
            $$= NEW_PTN Item_func_substr(@$, $3,$5,$7);
          }
|SUBSTRING '(' expr FROM expr ')' {
            $$= NEW_PTN Item_func_substr(@$, $3,$5);
          }
|SYSDATE func_datetime_precision {
            $$= NEW_PTN PTI_function_call_nonkeyword_sysdate(@$,
              static_cast<uint8>($2));
          }
|TIMESTAMP_ADD '(' interval_time_stamp ',' expr ',' expr ')' {
            $$= NEW_PTN Item_date_add_interval(@$, $7, $5, $3, 0);
          }
|TIMESTAMP_DIFF '(' interval_time_stamp ',' expr ',' expr ')' {
            $$= NEW_PTN Item_func_timestamp_diff(@$, $5,$7,$3);
          }
|UTC_DATE_SYM optional_braces {
            $$= NEW_PTN Item_func_curdate_utc(@$);
          }
|UTC_TIME_SYM func_datetime_precision {
            $$= NEW_PTN Item_func_curtime_utc(@$, static_cast<uint8>($2));
          }
|UTC_TIMESTAMP_SYM func_datetime_precision {
            $$= NEW_PTN Item_func_now_utc(@$, static_cast<uint8>($2));
          }
;

opt_returning_type:
%empty {
            $$= {ITEM_CAST_CHAR, nullptr, "512", nullptr};
          }
|RETURNING_SYM cast_type {
            $$= $2;
          }
;

function_call_conflict:
ASCII_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_ascii(@$, $3);
          }
|CHARSET '(' expr ')' {
            $$= NEW_PTN Item_func_charset(@$, $3);
          }
|COALESCE '(' expr_list ')' {
            $$= NEW_PTN Item_func_coalesce(@$, $3);
          }
|COLLATION_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_collation(@$, $3);
          }
|DATABASE '(' ')' {
            $$= NEW_PTN Item_func_database(@$);
          }
|IF '(' expr ',' expr ',' expr ')' {
            $$= NEW_PTN Item_func_if(@$, $3,$5,$7);
          }
|FORMAT_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_format(@$, $3, $5);
          }
|FORMAT_SYM '(' expr ',' expr ',' expr ')' {
            $$= NEW_PTN Item_func_format(@$, $3, $5, $7);
          }
|MICROSECOND_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_microsecond(@$, $3);
          }
|MOD_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_mod(@$, $3, $5);
          }
|QUARTER_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_quarter(@$, $3);
          }
|REPEAT_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_repeat(@$, $3,$5);
          }
|REPLACE_SYM '(' expr ',' expr ',' expr ')' {
            $$= NEW_PTN Item_func_replace(@$, $3,$5,$7);
          }
|REVERSE_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_reverse(@$, $3);
          }
|ROW_COUNT_SYM '(' ')' {
            $$= NEW_PTN Item_func_row_count(@$);
          }
|TRUNCATE_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_round(@$, $3,$5,1);
          }
|WEEK_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_week(@$, $3, nullptr);
          }
|WEEK_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_week(@$, $3, $5);
          }
|WEIGHT_STRING_SYM '(' expr ')' {
            $$= NEW_PTN Item_func_weight_string(@$, $3, 0, 0, 0);
          }
|WEIGHT_STRING_SYM '(' expr AS CHAR_SYM ws_num_codepoints ')' {
            $$= NEW_PTN Item_func_weight_string(@$, $3, 0, $6, 0);
          }
|WEIGHT_STRING_SYM '(' expr AS BINARY_SYM ws_num_codepoints ')' {
            $$= NEW_PTN Item_func_weight_string(@$, $3, 0, $6, 0, true);
          }
|WEIGHT_STRING_SYM '(' expr ',' ulong_num ',' ulong_num ',' ulong_num ')' {
            $$= NEW_PTN Item_func_weight_string(@$, $3, $5, $7, $9);
          }
|geometry_function 
;

geometry_function:
GEOMETRYCOLLECTION_SYM '(' opt_expr_list ')' {
            $$= NEW_PTN Item_func_spatial_collection(@$, $3,
                        Geometry::wkb_geometrycollection,
                        Geometry::wkb_point);
          }
|LINESTRING_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_spatial_collection(@$, $3,
                        Geometry::wkb_linestring,
                        Geometry::wkb_point);
          }
|MULTILINESTRING_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_spatial_collection(@$, $3,
                        Geometry::wkb_multilinestring,
                        Geometry::wkb_linestring);
          }
|MULTIPOINT_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_spatial_collection(@$, $3,
                        Geometry::wkb_multipoint,
                        Geometry::wkb_point);
          }
|MULTIPOLYGON_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_spatial_collection(@$, $3,
                        Geometry::wkb_multipolygon,
                        Geometry::wkb_polygon);
          }
|POINT_SYM '(' expr ',' expr ')' {
            $$= NEW_PTN Item_func_point(@$, $3,$5);
          }
|POLYGON_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_spatial_collection(@$, $3,
                        Geometry::wkb_polygon,
                        Geometry::wkb_linestring);
          }
;

function_call_generic:
IDENT_sys '(' opt_udf_expr_list ')' {
            $$= NEW_PTN PTI_function_call_generic_ident_sys(@$, $1, $3);
          }
|ident '.' ident '(' opt_expr_list ')' {
            $$= NEW_PTN PTI_function_call_generic_2d(@$, $1, $3, $5);
          }
;

fulltext_options:
opt_natural_language_mode opt_query_expansion { $$= $1 | $2; }
|IN_SYM BOOLEAN_SYM MODE_SYM {
            $$= FT_BOOL;
            DBUG_EXECUTE_IF("simulate_bug18831513",
                            {
                              THD *thd= YYTHD;
                              if (thd->sp_runtime_ctx)
                                YYTHD->syntax_error();
                            });
          }
;

opt_natural_language_mode:
%empty { $$= FT_NL; }
|IN_SYM NATURAL LANGUAGE_SYM MODE_SYM { $$= FT_NL; }
;

opt_query_expansion:
%empty { $$= 0;         }
|WITH QUERY_SYM EXPANSION_SYM { $$= FT_EXPAND; }
;

opt_udf_expr_list:
%empty { $$= nullptr; }
|udf_expr_list { $$= $1; }
;

udf_expr_list:
udf_expr {
            $$= NEW_PTN PT_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|udf_expr_list ',' udf_expr {
            if ($1 == nullptr || $1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
            
            
            $$->m_pos = @$;
          }
;

udf_expr:
expr select_alias {
            $$= NEW_PTN PTI_udf_expr(@$, $1, $2, @1.cpp);
          }
;

set_function_specification:
sum_expr 
|grouping_operation 
;

sum_expr:
AVG_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_avg(@$, $3, false, $5);
          }
|AVG_SYM '(' DISTINCT in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_avg(@$, $4, true, $6);
          }
|BIT_AND_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_and(@$, $3, $5);
          }
|BIT_OR_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_or(@$, $3, $5);
          }
|JSON_ARRAYAGG '(' in_sum_expr ')' opt_windowing_clause {
            auto wrapper = make_unique_destroy_only<Json_wrapper>(YYMEM_ROOT);
            if (wrapper == nullptr) YYABORT;
            unique_ptr_destroy_only<Json_array> array{::new (YYMEM_ROOT)
                                                          Json_array};
            if (array == nullptr) YYABORT;
            $$ = NEW_PTN Item_sum_json_array(@$, $3, $5, std::move(wrapper),
                                             std::move(array));
          }
|JSON_OBJECTAGG '(' in_sum_expr ',' in_sum_expr ')' opt_windowing_clause {
            auto wrapper = make_unique_destroy_only<Json_wrapper>(YYMEM_ROOT);
            if (wrapper == nullptr) YYABORT;
            unique_ptr_destroy_only<Json_object> object{::new (YYMEM_ROOT)
                                                            Json_object};
            if (object == nullptr) YYABORT;
            $$ = NEW_PTN Item_sum_json_object(
                @$, $3, $5, $7, std::move(wrapper), std::move(object));
          }
|ST_COLLECT_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_collect(@$, $3, $5, false);
          }
|ST_COLLECT_SYM '(' DISTINCT in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_collect(@$, $4, $6, true );
          }
|BIT_XOR_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_xor(@$, $3, $5);
          }
|COUNT_SYM '(' opt_all '*' ')' opt_windowing_clause {
            $$= NEW_PTN PTI_count_sym(@$, $6);
          }
|COUNT_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_count(@$, $3, $5);
          }
|COUNT_SYM '(' DISTINCT expr_list ')' opt_windowing_clause {
            $$= new Item_sum_count(@$, $4, $6);
          }
|MIN_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_min(@$, $3, $5);
          }
|MIN_SYM '(' DISTINCT in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_min(@$, $4, $6);
          }
|MAX_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_max(@$, $3, $5);
          }
|MAX_SYM '(' DISTINCT in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_max(@$, $4, $6);
          }
|STD_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_std(@$, $3, 0, $5);
          }
|VARIANCE_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_variance(@$, $3, 0, $5);
          }
|STDDEV_SAMP_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_std(@$, $3, 1, $5);
          }
|VAR_SAMP_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_variance(@$, $3, 1, $5);
          }
|SUM_SYM '(' in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_sum(@$, $3, false, $5);
          }
|SUM_SYM '(' DISTINCT in_sum_expr ')' opt_windowing_clause {
            $$= NEW_PTN Item_sum_sum(@$, $4, true, $6);
          }
|GROUP_CONCAT_SYM '(' opt_distinct expr_list opt_gorder_clause opt_gconcat_separator ')' opt_windowing_clause {
            $$= NEW_PTN Item_func_group_concat(@$, $3, $4, $5, $6, $8);
          }
;

sampling_method:
SYSTEM_SYM { $$= tablesample_type::SYSTEM_TABLESAMPLE_TYPE;    }
|BERNOULLI_SYM { $$= tablesample_type::BERNOULLI_TABLESAMPLE_TYPE; }
;

sampling_percentage:
NUM_literal { $$ = $1; }
|'@' ident_or_text { $$ = NEW_PTN PTI_user_variable(@$, $2); }
|param_marker { $$ = $1; }
;

opt_tablesample_clause:
%empty {
             { $$= nullptr; }
          }
|TABLESAMPLE_SYM sampling_method '(' sampling_percentage ')' {
            $$= NEW_PTN PT_tablesample(@$,$2,$4);
          }
;

window_func_call:
ROW_NUMBER_SYM '(' ')' windowing_clause {
            $$=  NEW_PTN Item_row_number(@$, $4);
          }
|RANK_SYM '(' ')' windowing_clause {
            $$= NEW_PTN Item_rank(@$, false, $4);
          }
|DENSE_RANK_SYM '(' ')' windowing_clause {
            $$= NEW_PTN Item_rank(@$, true, $4);
          }
|CUME_DIST_SYM '(' ')' windowing_clause {
            $$=  NEW_PTN Item_cume_dist(@$, $4);
          }
|PERCENT_RANK_SYM '(' ')' windowing_clause {
            $$= NEW_PTN Item_percent_rank(@$, $4);
          }
|NTILE_SYM '(' stable_integer ')' windowing_clause {
            $$=NEW_PTN Item_ntile(@$, $3, $5);
          }
|LEAD_SYM '(' expr opt_lead_lag_info ')' opt_null_treatment windowing_clause {
            PT_item_list *args= NEW_PTN PT_item_list(@expr, @opt_lead_lag_info);
            if (args == nullptr || args->push_back($3))
              MYSQL_YYABORT; 
            if ($4.offset != nullptr && args->push_back($4.offset))
              MYSQL_YYABORT; 
            if ($4.default_value != nullptr && args->push_back($4.default_value))
              MYSQL_YYABORT; 
            $$= NEW_PTN Item_lead_lag(@$, true, args, $6, $7);
          }
|LAG_SYM '(' expr opt_lead_lag_info ')' opt_null_treatment windowing_clause {
            PT_item_list *args= NEW_PTN PT_item_list(@expr, @opt_lead_lag_info);
            if (args == nullptr || args->push_back($3))
              MYSQL_YYABORT; 
            if ($4.offset != nullptr && args->push_back($4.offset))
              MYSQL_YYABORT; 
            if ($4.default_value != nullptr && args->push_back($4.default_value))
              MYSQL_YYABORT; 
            $$= NEW_PTN Item_lead_lag(@$, false, args, $6, $7);
          }
|FIRST_VALUE_SYM '(' expr ')' opt_null_treatment windowing_clause {
            $$= NEW_PTN Item_first_last_value(@$, true, $3, $5, $6);
          }
|LAST_VALUE_SYM '(' expr ')' opt_null_treatment windowing_clause {
            $$= NEW_PTN Item_first_last_value(@$, false, $3, $5, $6);
          }
|NTH_VALUE_SYM '(' expr ',' simple_expr ')' opt_from_first_last opt_null_treatment windowing_clause {
            PT_item_list *args= NEW_PTN PT_item_list(@expr, @simple_expr);
            if (args == nullptr ||
                args->push_back($3) ||
                args->push_back($5))
              MYSQL_YYABORT;
            $$= NEW_PTN Item_nth_value(@$, args, $7 == NFL_FROM_LAST, $8, $9);
          }
;

opt_lead_lag_info:
%empty {
            $$.offset= nullptr;
            $$.default_value= nullptr;
          }
|',' stable_integer opt_ll_default {
            $$.offset= $2;
            $$.default_value= $3;
          }
;

stable_integer:
int64_literal { $$ = $1; }
|param_or_var 
;

param_or_var:
param_marker { $$ = $1; }
|ident { $$ = NEW_PTN PTI_int_splocal(@$, to_lex_cstring($1)); }
|'@' ident_or_text { $$ = NEW_PTN PTI_user_variable(@$, $2); }
;

opt_ll_default:
%empty {
            $$= nullptr;
          }
|',' expr {
            $$= $2;
          }
;

opt_null_treatment:
%empty {
            $$= NT_NONE;
          }
|RESPECT_SYM NULLS_SYM {
            $$= NT_RESPECT_NULLS;
          }
|IGNORE_SYM NULLS_SYM {
            $$= NT_IGNORE_NULLS;
          }
;

opt_from_first_last:
%empty {
            $$= NFL_NONE;
          }
|FROM FIRST_SYM {
            $$= NFL_FROM_FIRST;
          }
|FROM LAST_SYM {
            $$= NFL_FROM_LAST;
          }
;

opt_windowing_clause:
%empty {
            $$= nullptr;
          }
|windowing_clause {
            $$= $1;
          }
;

windowing_clause:
OVER_SYM window_name_or_spec {
            $$= $2;
          }
;

window_name_or_spec:
window_name {
            $$= NEW_PTN PT_window(@$, $1);
          }
|window_spec {
            $$= $1;
          }
;

window_name:
ident {
            $$= NEW_PTN Item_string($1.str, $1.length, YYTHD->charset());
          }
;

window_spec:
'(' window_spec_details ')' {
            $$= $2;
            if ($$ != nullptr) $$->m_pos = @$;
          }
;

window_spec_details:
opt_existing_window_name opt_partition_clause opt_window_order_by_clause opt_window_frame_clause {
             auto frame= $4;
             if (!frame) 
             {
               auto start_bound= NEW_PTN PT_border(POS(), WBT_UNBOUNDED_PRECEDING);
               auto end_bound= NEW_PTN PT_border(POS(), $3 ? WBT_CURRENT_ROW :
                 WBT_UNBOUNDED_FOLLOWING);
               auto bounds= NEW_PTN PT_borders(POS(), start_bound, end_bound);
               frame= NEW_PTN PT_frame(POS(), WFU_RANGE, bounds, nullptr);
               frame->m_originally_absent= true;
             }
             $$= NEW_PTN PT_window(POS(), $2, $3, frame, $1);
           }
;

opt_existing_window_name:
%empty {
            $$= nullptr;
          }
|window_name {
            $$= $1;
          }
;

opt_partition_clause:
%empty {
            $$= nullptr;
          }
|PARTITION_SYM BY group_list {
            $$= $3;
            if ($$ != nullptr) $$->m_pos = @$;
          }
;

opt_window_order_by_clause:
%empty {
            $$= nullptr;
          }
|ORDER_SYM BY order_list {
            $$= $3;
            if ($$ != nullptr) $$->m_pos = @$;
          }
;

opt_window_frame_clause:
%empty {
            $$= nullptr;
          }
|window_frame_units window_frame_extent opt_window_frame_exclusion {
            $$= NEW_PTN PT_frame(@$, $1, $2, $3);
          }
;

window_frame_extent:
window_frame_start {
            auto end_bound= NEW_PTN PT_border(@$, WBT_CURRENT_ROW);
            $$= NEW_PTN PT_borders(@$, $1, end_bound);
          }
|window_frame_between {
            $$= $1;
          }
;

window_frame_start:
UNBOUNDED_SYM PRECEDING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_UNBOUNDED_PRECEDING);
          }
|NUM_literal PRECEDING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_VALUE_PRECEDING, $1);
          }
|param_marker PRECEDING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_VALUE_PRECEDING, $1);
          }
|INTERVAL_SYM expr interval PRECEDING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_VALUE_PRECEDING, $2, $3);
          }
|CURRENT_SYM ROW_SYM {
            $$= NEW_PTN PT_border(@$, WBT_CURRENT_ROW);
          }
;

window_frame_between:
BETWEEN_SYM window_frame_bound AND_SYM window_frame_bound {
            $$= NEW_PTN PT_borders(@$, $2, $4);
          }
;

window_frame_bound:
window_frame_start {
            $$= $1;
          }
|UNBOUNDED_SYM FOLLOWING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_UNBOUNDED_FOLLOWING);
          }
|NUM_literal FOLLOWING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_VALUE_FOLLOWING, $1);
          }
|param_marker FOLLOWING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_VALUE_FOLLOWING, $1);
          }
|INTERVAL_SYM expr interval FOLLOWING_SYM {
            $$= NEW_PTN PT_border(@$, WBT_VALUE_FOLLOWING, $2, $3);
          }
;

opt_window_frame_exclusion:
%empty {
            $$= nullptr;
          }
|EXCLUDE_SYM CURRENT_SYM ROW_SYM {
            $$= NEW_PTN PT_exclusion(@$, WFX_CURRENT_ROW);
          }
|EXCLUDE_SYM GROUP_SYM {
            $$= NEW_PTN PT_exclusion(@$, WFX_GROUP);
          }
|EXCLUDE_SYM TIES_SYM {
            $$= NEW_PTN PT_exclusion(@$, WFX_TIES);
          }
|EXCLUDE_SYM NO_SYM OTHERS_SYM { $$= NEW_PTN PT_exclusion(@$, WFX_NO_OTHERS);
          }
;

window_frame_units:
ROWS_SYM { $$= WFU_ROWS; }
|RANGE_SYM { $$= WFU_RANGE; }
|GROUPS_SYM { $$= WFU_GROUPS; }
;

grouping_operation:
GROUPING_SYM '(' expr_list ')' {
            $$= NEW_PTN Item_func_grouping(@$, $3);
          }
;

in_expression_user_variable_assignment:
'@' ident_or_text SET_VAR expr {
            push_warning(YYTHD, Sql_condition::SL_WARNING,
                         ER_WARN_DEPRECATED_SYNTAX,
                         ER_THD(YYTHD, ER_WARN_DEPRECATED_USER_SET_EXPR));
            $$ = NEW_PTN PTI_variable_aux_set_var(@$, $2, $4);
          }
;

rvalue_system_or_user_variable:
'@' ident_or_text {
            $$ = NEW_PTN PTI_user_variable(@$, $2);
          }
|'@' '@' opt_rvalue_system_variable_type rvalue_system_variable {
            $$ = NEW_PTN PTI_get_system_variable(@$, $3,
                                                 @4, $4.prefix, $4.name);
          }
;

opt_distinct:
%empty { $$ = 0; }
|DISTINCT { $$ = 1; }
;

opt_gconcat_separator:
%empty {
            $$= NEW_PTN String(",", 1, &my_charset_latin1);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|SEPARATOR_SYM text_string { $$ = $2; }
;

opt_gorder_clause:
%empty { $$= nullptr; }
|ORDER_SYM BY gorder_list { $$= $3; }
;

gorder_list:
gorder_list ',' order_expr {
            $1->push_back($3);
            $$= $1;
            
            
            $$->m_pos = @$;
          }
|order_expr {
            $$= NEW_PTN PT_gorder_list(@$);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
;

in_sum_expr:
opt_all expr {
            $$= NEW_PTN PTI_in_sum_expr(@1, $2);
          }
;

cast_type:
BINARY_SYM opt_field_length {
            $$.target= ITEM_CAST_CHAR;
            $$.charset= &my_charset_bin;
            $$.length= $2;
            $$.dec= nullptr;
          }
|CHAR_SYM opt_field_length opt_charset_with_opt_binary {
            $$.target= ITEM_CAST_CHAR;
            $$.length= $2;
            $$.dec= nullptr;
            if ($3.force_binary)
            {
              
              
              

              $$.charset= get_bin_collation($3.charset ? $3.charset :
                  YYTHD->variables.collation_connection);
              if ($$.charset == nullptr)
                MYSQL_YYABORT;
            }
            else
              $$.charset= $3.charset;
          }
|nchar opt_field_length {
            $$.target= ITEM_CAST_CHAR;
            $$.charset= national_charset_info;
            $$.length= $2;
            $$.dec= nullptr;
            warn_about_deprecated_national(YYTHD);
          }
|SIGNED_SYM {
            $$.target= ITEM_CAST_SIGNED_INT;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|SIGNED_SYM INT_SYM {
            $$.target= ITEM_CAST_SIGNED_INT;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|UNSIGNED_SYM {
            $$.target= ITEM_CAST_UNSIGNED_INT;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|UNSIGNED_SYM INT_SYM {
            $$.target= ITEM_CAST_UNSIGNED_INT;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|DATE_SYM {
            $$.target= ITEM_CAST_DATE;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|YEAR_SYM {
            $$.target= ITEM_CAST_YEAR;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|TIME_SYM type_datetime_precision {
            $$.target= ITEM_CAST_TIME;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= $2;
          }
|DATETIME_SYM type_datetime_precision {
            $$.target= ITEM_CAST_DATETIME;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= $2;
          }
|DECIMAL_SYM float_options {
            $$.target=ITEM_CAST_DECIMAL;
            $$.charset= nullptr;
            $$.length= $2.length;
            $$.dec= $2.dec;
          }
|JSON_SYM {
            $$.target=ITEM_CAST_JSON;
            $$.charset= nullptr;
            $$.length= nullptr;
            $$.dec= nullptr;
          }
|real_type {
            $$.target = ($1 == Numeric_type::DOUBLE) ?
              ITEM_CAST_DOUBLE : ITEM_CAST_FLOAT;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|FLOAT_SYM standard_float_options {
            $$.target = ITEM_CAST_FLOAT;
            $$.charset = nullptr;
            $$.length = $2.length;
            $$.dec = nullptr;
          }
|POINT_SYM {
            $$.target = ITEM_CAST_POINT;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|LINESTRING_SYM {
            $$.target = ITEM_CAST_LINESTRING;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|POLYGON_SYM {
            $$.target = ITEM_CAST_POLYGON;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|MULTIPOINT_SYM {
            $$.target = ITEM_CAST_MULTIPOINT;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|MULTILINESTRING_SYM {
            $$.target = ITEM_CAST_MULTILINESTRING;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|MULTIPOLYGON_SYM {
            $$.target = ITEM_CAST_MULTIPOLYGON;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
|GEOMETRYCOLLECTION_SYM {
            $$.target = ITEM_CAST_GEOMETRYCOLLECTION;
            $$.charset = nullptr;
            $$.length = nullptr;
            $$.dec = nullptr;
          }
;

opt_expr_list:
%empty { $$= nullptr; }
|expr_list 
;

expr_list:
expr {
            $$= NEW_PTN PT_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|expr_list ',' expr {
            if ($1 == nullptr || $1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
            
            
            $$->m_pos = @$;
          }
;

ident_list_arg:
ident_list { $$= $1; }
|'(' ident_list ')' { $$= $2; }
;

ident_list:
simple_ident {
            $$= NEW_PTN PT_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|ident_list ',' simple_ident {
            if ($1 == nullptr || $1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
            $$->m_pos = @$;
          }
;

opt_expr:
%empty { $$= nullptr; }
|expr { $$= $1; }
;

opt_else:
%empty { $$= nullptr; }
|ELSE expr { $$= $2; }
;

when_list:
WHEN_SYM expr THEN_SYM expr {
            $$= new (YYMEM_ROOT) mem_root_deque<Item *>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($2);
            $$->push_back($4);
          }
|when_list WHEN_SYM expr THEN_SYM expr {
            $1->push_back($3);
            $1->push_back($5);
            $$= $1;
          }
;

table_reference:
table_factor { $$= $1; }
|joined_table { $$= $1; }
|'{' OJ_SYM esc_table_reference '}' {
            
            $$ = $3;
          }
;

esc_table_reference:
table_factor { $$= $1; }
|joined_table { $$= $1; }
;

joined_table:
table_reference inner_join_type table_reference ON_SYM expr {
            $$= NEW_PTN PT_joined_table_on(@$, $1, @2, $2, $3, $5);
          }
|table_reference inner_join_type table_reference USING '(' using_list ')' {
            $$= NEW_PTN PT_joined_table_using(@$, $1, @2, $2, $3, $6);
          }
|table_reference outer_join_type table_reference ON_SYM expr {
            $$= NEW_PTN PT_joined_table_on(@$, $1, @2, $2, $3, $5);
          }
|table_reference outer_join_type table_reference USING '(' using_list ')' {
            $$= NEW_PTN PT_joined_table_using(@$, $1, @2, $2, $3, $6);
          }
|table_reference inner_join_type table_reference %prec CONDITIONLESS_JOIN {
            auto this_cross_join= NEW_PTN PT_cross_join(@$, $1, @2, $2, nullptr);

            if ($3 == nullptr)
              MYSQL_YYABORT; 

            $$= $3->add_cross_join(this_cross_join);
          }
|table_reference natural_join_type table_factor {
            $$= NEW_PTN PT_joined_table_using(@$, $1, @2, $2, $3);
          }
;

natural_join_type:
NATURAL opt_inner JOIN_SYM { $$= JTT_NATURAL_INNER; }
|NATURAL RIGHT opt_outer JOIN_SYM { $$= JTT_NATURAL_RIGHT; }
|NATURAL LEFT opt_outer JOIN_SYM { $$= JTT_NATURAL_LEFT; }
;

inner_join_type:
JOIN_SYM { $$= JTT_INNER; }
|INNER_SYM JOIN_SYM { $$= JTT_INNER; }
|CROSS JOIN_SYM { $$= JTT_INNER; }
|STRAIGHT_JOIN { $$= JTT_STRAIGHT_INNER; }

outer_join_type:
LEFT opt_outer JOIN_SYM { $$= JTT_LEFT; }
|RIGHT opt_outer JOIN_SYM { $$= JTT_RIGHT; }
;

opt_inner:
%empty 
|INNER_SYM 
;

opt_outer:
%empty 
|OUTER_SYM 
;

opt_use_partition:
%empty { $$= nullptr; }
|use_partition 
;

use_partition:
PARTITION_SYM '(' using_list ')' {
            $$= $3;
          }
;

table_factor:
single_table 
|single_table_parens 
|derived_table { $$ = $1; }
|joined_table_parens { $$= NEW_PTN PT_table_factor_joined_table(@$, $1); }
|table_reference_list_parens { $$= NEW_PTN PT_table_reference_list_parens(@$, $1); }
|table_function { $$ = $1; }
;

table_reference_list_parens:
'(' table_reference_list_parens ')' { $$= $2; }
|'(' table_reference_list ',' table_reference ')' {
            $$= $2;
            if ($$.push_back($4))
              MYSQL_YYABORT; 
          }
;

single_table_parens:
'(' single_table_parens ')' { $$= $2; }
|'(' single_table ')' { $$= $2; }
;

single_table:
table_ident opt_use_partition opt_table_alias opt_key_definition opt_tablesample_clause {
            $$= NEW_PTN PT_table_factor_table_ident(@$, $1, $2, $3, $4, $5);
          }
;

joined_table_parens:
'(' joined_table_parens ')' { $$= $2; }
|'(' joined_table ')' { $$= $2; }
;

derived_table:
table_subquery opt_table_alias opt_derived_column_list {
            
            if ($2.str == nullptr)
              my_message(ER_DERIVED_MUST_HAVE_ALIAS,
                         ER_THD(YYTHD, ER_DERIVED_MUST_HAVE_ALIAS), MYF(0));

            $$= NEW_PTN PT_derived_table(@$, false, $1, $2, &$3);
          }
|LATERAL_SYM table_subquery opt_table_alias opt_derived_column_list {
            if ($3.str == nullptr)
              my_message(ER_DERIVED_MUST_HAVE_ALIAS,
                         ER_THD(YYTHD, ER_DERIVED_MUST_HAVE_ALIAS), MYF(0));

            $$= NEW_PTN PT_derived_table(@$, true, $2, $3, &$4);
          }
;

table_function:
JSON_TABLE_SYM '(' expr ',' text_literal columns_clause ')' opt_table_alias {
            
            if ($8 == NULL_CSTR)
            {
              my_message(ER_TF_MUST_HAVE_ALIAS,
                         ER_THD(YYTHD, ER_TF_MUST_HAVE_ALIAS), MYF(0));
              MYSQL_YYABORT;
            }

            $$= NEW_PTN PT_table_factor_function(@$, $3, $5, $6, to_lex_string($8));
          }
;

columns_clause:
COLUMNS '(' columns_list ')' {
            $$= $3;
          }
;

columns_list:
jt_column {
            $$= NEW_PTN Mem_root_array<PT_json_table_column *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|columns_list ',' jt_column {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

jt_column:
ident FOR_SYM ORDINALITY_SYM {
            $$= NEW_PTN PT_json_table_column_for_ordinality(@$, $1);
          }
|ident type opt_collate jt_column_type PATH_SYM text_literal opt_on_empty_or_error_json_table {
            auto column = make_unique_destroy_only<Json_table_column>(
                YYMEM_ROOT, $4, $6, $7.error.type, $7.error.default_string,
                $7.empty.type, $7.empty.default_string);
            if (column == nullptr) MYSQL_YYABORT;  
            $$ = NEW_PTN PT_json_table_column_with_path(@$, std::move(column), $1,
                                                        $2, $3);
          }
|NESTED_SYM PATH_SYM text_literal columns_clause {
            $$= NEW_PTN PT_json_table_column_with_nested_path(@$, $3, $4);
          }
;

jt_column_type:
%empty {
            $$= enum_jt_column::JTC_PATH;
          }
|EXISTS {
            $$= enum_jt_column::JTC_EXISTS;
          }
;

opt_on_empty_or_error:
%empty {
            $$.empty = {Json_on_response_type::IMPLICIT, nullptr};
            $$.error = {Json_on_response_type::IMPLICIT, nullptr};
          }
|on_empty {
            $$.empty = $1;
            $$.error = {Json_on_response_type::IMPLICIT, nullptr};
          }
|on_error {
            $$.error = $1;
            $$.empty = {Json_on_response_type::IMPLICIT, nullptr};
          }
|on_empty on_error {
            $$.empty = $1;
            $$.error = $2;
          }
;

opt_on_empty_or_error_json_table:
opt_on_empty_or_error { $$ = $1; }
|on_error on_empty {
            push_warning(
              YYTHD, Sql_condition::SL_WARNING, ER_WARN_DEPRECATED_SYNTAX,
              ER_THD(YYTHD, ER_WARN_DEPRECATED_JSON_TABLE_ON_ERROR_ON_EMPTY));
            $$.error = $1;
            $$.empty = $2;
          }
;

on_empty:
json_on_response ON_SYM EMPTY_SYM { $$= $1; }
;

on_error:
json_on_response ON_SYM ERROR_SYM { $$= $1; }
;

json_on_response:
ERROR_SYM {
            $$ = {Json_on_response_type::ERROR, nullptr};
          }
|NULL_SYM {
            $$ = {Json_on_response_type::NULL_VALUE, nullptr};
          }
|DEFAULT_SYM signed_literal {
            $$ = {Json_on_response_type::DEFAULT, $2};
          }
;

index_hint_clause:
%empty {
            $$= INDEX_HINT_MASK_ALL;
          }
|FOR_SYM JOIN_SYM { $$= INDEX_HINT_MASK_JOIN;  }
|FOR_SYM ORDER_SYM BY { $$= INDEX_HINT_MASK_ORDER; }
|FOR_SYM GROUP_SYM BY { $$= INDEX_HINT_MASK_GROUP; }
;

index_hint_type:
FORCE_SYM { $$= INDEX_HINT_FORCE; }
|IGNORE_SYM { $$= INDEX_HINT_IGNORE; }
;

index_hint_definition:
index_hint_type key_or_index index_hint_clause '(' key_usage_list ')' {
            init_index_hints($5, $1, $3);
            $$= $5;
          }
|USE_SYM key_or_index index_hint_clause '(' opt_key_usage_list ')' {
            init_index_hints($5, INDEX_HINT_USE, $3);
            $$= $5;
          }
;

index_hints_list:
index_hint_definition 
|index_hints_list index_hint_definition {
            $2->concat($1);
            $$= $2;
          }
;

opt_index_hints_list:
%empty { $$= nullptr; }
|index_hints_list 
;

opt_key_definition:
opt_index_hints_list 
;

opt_key_usage_list:
%empty {
            $$= NEW_PTN List<Index_hint>;
            Index_hint *hint= NEW_PTN Index_hint(nullptr, 0);
            if ($$ == nullptr || hint == nullptr || $$->push_front(hint))
              MYSQL_YYABORT;
          }
|key_usage_list 
;

key_usage_element:
ident {
            $$= NEW_PTN Index_hint($1.str, $1.length);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|PRIMARY_SYM {
            $$= NEW_PTN Index_hint(STRING_WITH_LEN("PRIMARY"));
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

key_usage_list:
key_usage_element {
            $$= NEW_PTN List<Index_hint>;
            if ($$ == nullptr || $$->push_front($1))
              MYSQL_YYABORT;
          }
|key_usage_list ',' key_usage_element {
            if ($$->push_front($3))
              MYSQL_YYABORT;
          }
;

using_list:
ident_string_list 
;

ident_string_list:
ident {
            $$= NEW_PTN List<String>;
            String *s= NEW_PTN String(const_cast<const char *>($1.str),
                                               $1.length,
                                               system_charset_info);
            if ($$ == nullptr || s == nullptr || $$->push_back(s))
              MYSQL_YYABORT;
          }
|ident_string_list ',' ident {
            String *s= NEW_PTN String(const_cast<const char *>($3.str),
                                               $3.length,
                                               system_charset_info);
            if (s == nullptr || $1->push_back(s))
              MYSQL_YYABORT;
            $$= $1;
          }
;

interval:
interval_time_stamp {}
|DAY_HOUR_SYM { $$=INTERVAL_DAY_HOUR; }
|DAY_MICROSECOND_SYM { $$=INTERVAL_DAY_MICROSECOND; }
|DAY_MINUTE_SYM { $$=INTERVAL_DAY_MINUTE; }
|DAY_SECOND_SYM { $$=INTERVAL_DAY_SECOND; }
|HOUR_MICROSECOND_SYM { $$=INTERVAL_HOUR_MICROSECOND; }
|HOUR_MINUTE_SYM { $$=INTERVAL_HOUR_MINUTE; }
|HOUR_SECOND_SYM { $$=INTERVAL_HOUR_SECOND; }
|MINUTE_MICROSECOND_SYM { $$=INTERVAL_MINUTE_MICROSECOND; }
|MINUTE_SECOND_SYM { $$=INTERVAL_MINUTE_SECOND; }
|SECOND_MICROSECOND_SYM { $$=INTERVAL_SECOND_MICROSECOND; }
|YEAR_MONTH_SYM { $$=INTERVAL_YEAR_MONTH; }
;

interval_time_stamp:
DAY_SYM { $$=INTERVAL_DAY; }
|WEEK_SYM { $$=INTERVAL_WEEK; }
|HOUR_SYM { $$=INTERVAL_HOUR; }
|MINUTE_SYM { $$=INTERVAL_MINUTE; }
|MONTH_SYM { $$=INTERVAL_MONTH; }
|QUARTER_SYM { $$=INTERVAL_QUARTER; }
|SECOND_SYM { $$=INTERVAL_SECOND; }
|MICROSECOND_SYM { $$=INTERVAL_MICROSECOND; }
|YEAR_SYM { $$=INTERVAL_YEAR; }
;

date_time_type:
DATE_SYM {$$= MYSQL_TIMESTAMP_DATE; }
|TIME_SYM {$$= MYSQL_TIMESTAMP_TIME; }
|TIMESTAMP_SYM {$$= MYSQL_TIMESTAMP_DATETIME; }
|DATETIME_SYM {$$= MYSQL_TIMESTAMP_DATETIME; }
;

opt_as:
%empty 
|AS 
;

opt_table_alias:
%empty { $$ = NULL_CSTR; }
|opt_as ident { $$ = to_lex_cstring($2); }
;

opt_all:
%empty 
|ALL 
;

opt_where_clause:
%empty { $$ = nullptr; }
|where_clause 
;

where_clause:
WHERE expr { $$ = NEW_PTN PTI_where(@2, $2); }
;

opt_having_clause:
%empty { $$= nullptr; }
|HAVING expr {
            $$= new PTI_having(@$, $2);
          }
;

opt_qualify_clause:
%empty { $$= nullptr; }
|QUALIFY_SYM expr {
            $$= new PTI_qualify(@$, $2);
          }
;

with_clause:
WITH with_list {
            $$= NEW_PTN PT_with_clause(@$, $2, false);
          }
|WITH RECURSIVE_SYM with_list {
            $$= NEW_PTN PT_with_clause(@$, $3, true);
          }
;

with_list:
with_list ',' common_table_expr {
            if ($1->push_back($3))
              MYSQL_YYABORT;
            $$->m_pos = @$;
          }
|common_table_expr {
            $$= NEW_PTN PT_with_list(@$, YYTHD->mem_root);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;    
          }
;

common_table_expr:
ident opt_derived_column_list AS table_subquery {
            LEX_STRING subq_text;
            subq_text.length= @4.cpp.length();
            subq_text.str= YYTHD->strmake(@4.cpp.start, subq_text.length);
            if (subq_text.str == nullptr)
              MYSQL_YYABORT;   
            uint subq_text_offset= @4.cpp.start - YYLIP->get_cpp_buf();
            $$= NEW_PTN PT_common_table_expr(@$, $1, subq_text, subq_text_offset,
                                             $4, &$2, YYTHD->mem_root);
            if ($$ == nullptr)
              MYSQL_YYABORT;   
          }
;

opt_derived_column_list:
%empty {
            
            $$.init(YYTHD->mem_root);
          }
|'(' simple_ident_list ')' {
            $$= $2;
          }
;

simple_ident_list:
ident {
            $$.init(YYTHD->mem_root);
            if ($$.push_back(to_lex_cstring($1)))
              MYSQL_YYABORT; 
          }
|simple_ident_list ',' ident {
            $$= $1;
            if ($$.push_back(to_lex_cstring($3)))
              MYSQL_YYABORT;  
          }
;

opt_window_clause:
%empty {
            $$= nullptr;
          }
|WINDOW_SYM window_definition_list {
            $$= $2;
          }
;

window_definition_list:
window_definition {
            $$= NEW_PTN PT_window_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|window_definition_list ',' window_definition {
            if ($1->push_back($3))
              MYSQL_YYABORT; 
            $$= $1;
            $$->m_pos = @$;
          }
;

window_definition:
window_name AS window_spec {
            $$= $3;
            if ($$ == nullptr)
              MYSQL_YYABORT; 
            $$->m_pos = @$;
            $$->set_name($1);
          }
;

opt_group_clause:
%empty { $$= nullptr; }
|GROUP_SYM BY group_list olap_opt {
            $$= NEW_PTN PT_group(@$, $3, $4);
          }
|GROUP_SYM BY ROLLUP_SYM '(' group_list ')' {
            $$= NEW_PTN PT_group(@$, $5, ROLLUP_TYPE);
          }
|GROUP_SYM BY CUBE_SYM '(' group_list ')' {
            $$= NEW_PTN PT_group(@$, $5, CUBE_TYPE);
          }
;

group_list:
group_list ',' grouping_expr {
            $1->push_back($3);
            $$= $1;
            $$->m_pos = @$;
          }
|grouping_expr {
            $$= NEW_PTN PT_order_list(@$);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
;

olap_opt:
%empty { $$= UNSPECIFIED_OLAP_TYPE; }
|WITH_ROLLUP_SYM { $$= ROLLUP_TYPE; }
;

alter_order_list:
alter_order_list ',' alter_order_item {
            $$= $1;
            $$->push_back($3);
            $$->m_pos = @$;
          }
|alter_order_item {
            $$= NEW_PTN PT_order_list(@$);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
;

alter_order_item:
simple_ident_nospvar opt_ordering_direction {
            $$= NEW_PTN PT_order_expr(@$, $1, $2);
          }
;

opt_order_clause:
%empty { $$= nullptr; }
|order_clause 
;

order_clause:
ORDER_SYM BY order_list {
            $$= NEW_PTN PT_order(@$, $3);
          }
;

order_list:
order_list ',' order_expr {
            $1->push_back($3);
            $$= $1;
            $$->m_pos = @$;
          }
|order_expr {
            $$= NEW_PTN PT_order_list(@$);
            if ($$ == nullptr)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
;

opt_ordering_direction:
%empty { $$= ORDER_NOT_RELEVANT; }
|ordering_direction 
;

ordering_direction:
ASC { $$= ORDER_ASC; }
|DESC { $$= ORDER_DESC; }
;

opt_limit_clause:
%empty { $$= nullptr; }
|limit_clause 
;

limit_clause:
LIMIT limit_options {
            $$= NEW_PTN PT_limit_clause(@$, $2);
          }
;

limit_options:
limit_option {
            $$.limit= $1;
            $$.opt_offset= nullptr;
            $$.is_offset_first= false;
          }
|limit_option ',' limit_option {
            $$.limit= $3;
            $$.opt_offset= $1;
            $$.is_offset_first= true;
          }
|limit_option OFFSET_SYM limit_option {
            $$.limit= $1;
            $$.opt_offset= $3;
            $$.is_offset_first= false;
          }
;

limit_option:
ident {
            $$= NEW_PTN PTI_limit_option_ident(@$, to_lex_cstring($1));
          }
|param_marker {
            $$= NEW_PTN PTI_limit_option_param_marker(@$, $1);
          }
|ULONGLONG_NUM {
            $$= NEW_PTN Item_uint(@$, $1.str, $1.length);
          }
|LONG_NUM {
            $$= NEW_PTN Item_uint(@$, $1.str, $1.length);
          }
|NUM {
            $$= NEW_PTN Item_uint(@$, $1.str, $1.length);
          }
;

opt_simple_limit:
%empty { $$= nullptr; }
|LIMIT limit_option { $$= $2; }
;

ulong_num:
NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|HEX_NUM { $$= (ulong) my_strtoll($1.str, nullptr, 16); }
|LONG_NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|ULONGLONG_NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|DECIMAL_NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|FLOAT_NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
;

real_ulong_num:
NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|HEX_NUM { $$= (ulong) my_strtoll($1.str, nullptr, 16); }
|LONG_NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|ULONGLONG_NUM { int error; $$= (ulong) my_strtoll10($1.str, nullptr, &error); }
|dec_num_error { MYSQL_YYABORT; }
;

ulonglong_num:
NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|ULONGLONG_NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|LONG_NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|DECIMAL_NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|FLOAT_NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
;

real_ulonglong_num:
NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|HEX_NUM { $$= (ulonglong) my_strtoll($1.str, nullptr, 16); }
|ULONGLONG_NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|LONG_NUM { int error; $$= (ulonglong) my_strtoll10($1.str, nullptr, &error); }
|dec_num_error { MYSQL_YYABORT; }
;

dec_num_error:
dec_num { YYTHD->syntax_error(ER_ONLY_INTEGERS_ALLOWED); }
;

dec_num:
DECIMAL_NUM 
|FLOAT_NUM 
;

select_var_list:
select_var_list ',' select_var_ident {
            $$= $1;
            if ($$ == nullptr || $$->push_back($3))
              MYSQL_YYABORT;
          }
|select_var_ident {
            $$= NEW_PTN PT_select_var_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
;

select_var_ident:
'@' ident_or_text {
            $$= NEW_PTN PT_select_var(@$, $2);
          }
|ident_or_text {
            $$= NEW_PTN PT_select_sp_var(@$, $1);
          }
;

into_clause:
INTO into_destination {
            $$= $2;
          }
;

into_destination:
OUTFILE TEXT_STRING_filesystem opt_load_data_charset opt_field_term opt_line_term {
            $$= NEW_PTN PT_into_destination_outfile(@$, $2, $3, $4, $5);
          }
|DUMPFILE TEXT_STRING_filesystem {
            $$= NEW_PTN PT_into_destination_dumpfile(@$, $2);
          }
|select_var_list { $$= $1; }
;

do_stmt:
DO_SYM select_item_list {
            $$= NEW_PTN PT_select_stmt(@$, SQLCOM_DO,
                  NEW_PTN PT_query_expression(@$,
                    NEW_PTN PT_query_specification(@$, {}, $2)));
          }
;

drop_table_stmt:
DROP opt_temporary table_or_tables if_exists table_list opt_restrict {
            
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_DROP_TABLE;
            lex->drop_temporary= $2;
            lex->drop_if_exists= $4;
            YYPS->m_lock_type= TL_UNLOCK;
            YYPS->m_mdl_type= MDL_EXCLUSIVE;
            if (Select->add_tables(YYTHD, $5, TL_OPTION_UPDATING,
                                   YYPS->m_lock_type, YYPS->m_mdl_type))
              MYSQL_YYABORT;

            Lex->m_sql_cmd= NEW_PTN Sql_cmd_drop_table();
            if (!Lex->m_sql_cmd)
              MYSQL_YYABORT;  
          }
;

drop_index_stmt:
DROP INDEX_SYM ident ON_SYM table_ident opt_index_lock_and_algorithm {
            $$= NEW_PTN PT_drop_index_stmt(@$, YYMEM_ROOT, $3.str, $5,
                                           $6.algo.get_or_default(),
                                           $6.lock.get_or_default());
          }
;

drop_database_stmt:
DROP DATABASE if_exists ident {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_DROP_DB;
            lex->drop_if_exists=$3;
            lex->name= $4;
            MAKE_CMD_DDL_DUMMY();
          }
;

drop_function_stmt:
DROP FUNCTION_SYM if_exists ident '.' ident {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_name *spname;
            if ($4.str &&
                (check_and_convert_db_name(&$4, false) != Ident_name_check::OK))
               MYSQL_YYABORT;
            if (sp_check_name(&$6))
               MYSQL_YYABORT;
            if (lex->sphead)
            {
              my_error(ER_SP_NO_DROP_SP, MYF(0), "FUNCTION");
              MYSQL_YYABORT;
            }
            lex->sql_command = SQLCOM_DROP_FUNCTION;
            lex->drop_if_exists= $3;
            spname= new (YYMEM_ROOT) sp_name(to_lex_cstring($4), $6, true);
            if (spname == nullptr)
              MYSQL_YYABORT;
            spname->init_qname(thd);
            lex->spname= spname;
            MAKE_CMD_DDL_DUMMY();
          }
|DROP FUNCTION_SYM if_exists ident {
            
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            LEX_STRING db= NULL_STR;
            sp_name *spname;
            if (lex->sphead)
            {
              my_error(ER_SP_NO_DROP_SP, MYF(0), "FUNCTION");
              MYSQL_YYABORT;
            }
            if (thd->db().str && lex->copy_db_to(&db.str, &db.length))
              MYSQL_YYABORT;
            if (sp_check_name(&$4))
               MYSQL_YYABORT;
            lex->sql_command = SQLCOM_DROP_FUNCTION;
            lex->drop_if_exists= $3;
            spname= new (YYMEM_ROOT) sp_name(to_lex_cstring(db), $4, false);
            if (spname == nullptr)
              MYSQL_YYABORT;
            spname->init_qname(thd);
            lex->spname= spname;
            MAKE_CMD_DDL_DUMMY();
          }
;

drop_resource_group_stmt:
DROP RESOURCE_SYM GROUP_SYM ident opt_force {
            $$= NEW_PTN PT_drop_resource_group(@$, to_lex_cstring($4), $5);
          }
;

drop_procedure_stmt:
DROP PROCEDURE_SYM if_exists sp_name {
            LEX *lex=Lex;
            if (lex->sphead)
            {
              my_error(ER_SP_NO_DROP_SP, MYF(0), "PROCEDURE");
              MYSQL_YYABORT;
            }
            lex->sql_command = SQLCOM_DROP_PROCEDURE;
            lex->drop_if_exists= $3;
            lex->spname= $4;
            MAKE_CMD_DDL_DUMMY();
          }
;

drop_user_stmt:
DROP USER if_exists user_list {
             LEX *lex=Lex;
             lex->sql_command= SQLCOM_DROP_USER;
             lex->drop_if_exists= $3;
             lex->users_list= *$4;
             MAKE_CMD_DCL_DUMMY();
          }
;

drop_view_stmt:
DROP VIEW_SYM if_exists table_list opt_restrict {
            
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_DROP_VIEW;
            lex->drop_if_exists= $3;
            YYPS->m_lock_type= TL_UNLOCK;
            YYPS->m_mdl_type= MDL_EXCLUSIVE;
            if (Select->add_tables(YYTHD, $4, TL_OPTION_UPDATING,
                                   YYPS->m_lock_type, YYPS->m_mdl_type))
              MYSQL_YYABORT;
            MAKE_CMD_DDL_DUMMY();
          }
;

drop_event_stmt:
DROP EVENT_SYM if_exists sp_name {
            Lex->drop_if_exists= $3;
            Lex->spname= $4;
            Lex->sql_command = SQLCOM_DROP_EVENT;
            MAKE_CMD_DDL_DUMMY();
          }
;

drop_trigger_stmt:
DROP TRIGGER_SYM if_exists sp_name {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_DROP_TRIGGER;
            lex->drop_if_exists= $3;
            lex->spname= $4;
            Lex->m_sql_cmd= new (YYTHD->mem_root) Sql_cmd_drop_trigger();
          }
;

drop_tablespace_stmt:
DROP TABLESPACE_SYM ident opt_drop_ts_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($4 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $4))
                MYSQL_YYABORT; 
            }

            auto cmd= NEW_PTN Sql_cmd_drop_tablespace{$3, pc};
            if (!cmd)
              MYSQL_YYABORT;  
            Lex->m_sql_cmd= cmd;
            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }

drop_undo_tablespace_stmt:
DROP UNDO_SYM TABLESPACE_SYM ident opt_undo_tablespace_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT; 

            if ($5 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $5))
                MYSQL_YYABORT;
            }

            auto cmd= NEW_PTN Sql_cmd_drop_undo_tablespace{
              DROP_UNDO_TABLESPACE, $4, {nullptr, 0},  pc};
            if (!cmd)
              MYSQL_YYABORT; 
            Lex->m_sql_cmd= cmd;
            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
;

drop_logfile_stmt:
DROP LOGFILE_SYM GROUP_SYM ident opt_drop_ts_options {
            auto pc= NEW_PTN Alter_tablespace_parse_context{YYTHD};
            if (pc == nullptr)
              MYSQL_YYABORT;  

            if ($5 != nullptr)
            {
              if (YYTHD->is_error() || contextualize_array(pc, $5))
                MYSQL_YYABORT; 
            }

            auto cmd= NEW_PTN Sql_cmd_logfile_group{DROP_LOGFILE_GROUP,
                                                    $4, pc};
            if (!cmd)
              MYSQL_YYABORT;  
            Lex->m_sql_cmd= cmd;
            Lex->sql_command= SQLCOM_ALTER_TABLESPACE;
          }
;

drop_server_stmt:
DROP SERVER_SYM if_exists ident_or_text {
            Lex->sql_command = SQLCOM_DROP_SERVER;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_drop_server($4, $3);
          }
;

drop_srs_stmt:
DROP SPATIAL_SYM REFERENCE_SYM SYSTEM_SYM if_exists real_ulonglong_num {
            $$= NEW_PTN PT_drop_srs(@$, $6, $5);
          }
;

drop_role_stmt:
DROP ROLE_SYM if_exists role_list {
            $$= NEW_PTN PT_drop_role(@$, $3, $4);
          }
;

table_list:
table_ident {
            $$= NEW_PTN Mem_root_array<Table_ident *>(YYMEM_ROOT);
            if ($$->push_back($1))
              MYSQL_YYABORT; 
          }
|table_list ',' table_ident {
            $$= $1;
            if ($$ == nullptr || $$->push_back($3))
              MYSQL_YYABORT; 
          }
;

table_alias_ref_list:
table_ident_opt_wild {
            $$.init(YYMEM_ROOT);
            if ($$.push_back($1))
              MYSQL_YYABORT; 
          }
|table_alias_ref_list ',' table_ident_opt_wild {
            $$= $1;
            if ($$.push_back($3))
              MYSQL_YYABORT; 
          }
;

if_exists:
%empty { $$= 0; }
|IF EXISTS { $$= 1; }
;

opt_ignore_unknown_user:
%empty { $$= 0; }
|IGNORE_SYM UNKNOWN_SYM USER { $$= 1; }
;

opt_temporary:
%empty { $$= false; }
|TEMPORARY { $$= true; }
;

opt_drop_ts_options:
%empty { $$= nullptr; }
|drop_ts_option_list 
;

drop_ts_option_list:
drop_ts_option {
            $$= NEW_PTN Mem_root_array<PT_alter_tablespace_option_base*>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;  
          }
|drop_ts_option_list opt_comma drop_ts_option {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;  
          }
;

drop_ts_option:
ts_option_engine 
|ts_option_wait 
;

insert_stmt:
INSERT_SYM insert_lock_option opt_ignore opt_INTO table_ident opt_use_partition insert_from_constructor opt_values_reference opt_insert_update_list {
            DBUG_EXECUTE_IF("bug29614521_simulate_oom",
                             DBUG_SET("+d,simulate_out_of_memory"););
            $$= NEW_PTN PT_insert(@$, false, $1, $2, $3, $5, $6,
                                  $7.column_list, $7.row_value_list,
                                  nullptr,
                                  $8.table_alias, $8.column_list,
                                  $9.column_list, $9.value_list);
            DBUG_EXECUTE_IF("bug29614521_simulate_oom",
                            DBUG_SET("-d,bug29614521_simulate_oom"););
          }
|INSERT_SYM insert_lock_option opt_ignore opt_INTO table_ident opt_use_partition SET_SYM update_list opt_values_reference opt_insert_update_list {
            PT_insert_values_list *one_row= NEW_PTN PT_insert_values_list(@$, YYMEM_ROOT);
            if (one_row == nullptr || one_row->push_back(&$8.value_list->value))
              MYSQL_YYABORT; 
            $$= NEW_PTN PT_insert(@$, false, $1, $2, $3, $5, $6,
                                  $8.column_list, one_row,
                                  nullptr,
                                  $9.table_alias, $9.column_list,
                                  $10.column_list, $10.value_list);
          }
|INSERT_SYM insert_lock_option opt_ignore opt_INTO table_ident opt_use_partition insert_query_expression opt_insert_update_list {
            $$= NEW_PTN PT_insert(@$, false, $1, $2, $3, $5, $6,
                                  $7.column_list, nullptr,
                                  $7.insert_query_expression,
                                  NULL_CSTR, nullptr,
                                  $8.column_list, $8.value_list);
          }
;

replace_stmt:
REPLACE_SYM replace_lock_option opt_INTO table_ident opt_use_partition insert_from_constructor {
            $$= NEW_PTN PT_insert(@$, true, $1, $2, false, $4, $5,
                                  $6.column_list, $6.row_value_list,
                                  nullptr,
                                  NULL_CSTR, nullptr,
                                  nullptr, nullptr);
          }
|REPLACE_SYM replace_lock_option opt_INTO table_ident opt_use_partition SET_SYM update_list {
            PT_insert_values_list *one_row= NEW_PTN PT_insert_values_list(@$, YYMEM_ROOT);
            if (one_row == nullptr || one_row->push_back(&$7.value_list->value))
              MYSQL_YYABORT; 
            $$= NEW_PTN PT_insert(@$, true, $1, $2, false, $4, $5,
                                  $7.column_list, one_row,
                                  nullptr,
                                  NULL_CSTR, nullptr,
                                  nullptr, nullptr);
          }
|REPLACE_SYM replace_lock_option opt_INTO table_ident opt_use_partition insert_query_expression {
            $$= NEW_PTN PT_insert(@$, true, $1, $2, false, $4, $5,
                                  $6.column_list, nullptr,
                                  $6.insert_query_expression,
                                  NULL_CSTR, nullptr,
                                  nullptr, nullptr);
          }
;

insert_lock_option:
%empty { $$= TL_WRITE_CONCURRENT_DEFAULT; }
|LOW_PRIORITY { $$= TL_WRITE_LOW_PRIORITY; }
|DELAYED_SYM {
          $$= TL_WRITE_CONCURRENT_DEFAULT;

          push_warning_printf(YYTHD, Sql_condition::SL_WARNING,
                              ER_WARN_LEGACY_SYNTAX_CONVERTED,
                              ER_THD(YYTHD, ER_WARN_LEGACY_SYNTAX_CONVERTED),
                              "INSERT DELAYED", "INSERT");
        }
|HIGH_PRIORITY { $$= TL_WRITE; }
;

replace_lock_option:
opt_low_priority { $$= $1; }
|DELAYED_SYM {
          $$= TL_WRITE_DEFAULT;

          push_warning_printf(YYTHD, Sql_condition::SL_WARNING,
                              ER_WARN_LEGACY_SYNTAX_CONVERTED,
                              ER_THD(YYTHD, ER_WARN_LEGACY_SYNTAX_CONVERTED),
                              "REPLACE DELAYED", "REPLACE");
        }
;

opt_INTO:
%empty 
|INTO 
;

insert_from_constructor:
insert_values {
            
            $$.column_list= NEW_PTN PT_item_list(POS());
            $$.row_value_list= $1;
          }
|'(' ')' insert_values {
            $$.column_list= NEW_PTN PT_item_list(POS()); 
            $$.row_value_list= $3;
          }
|'(' insert_columns ')' insert_values {
            $$.column_list= $2;
            $$.row_value_list= $4;
          }
;

insert_query_expression:
query_expression_with_opt_locking_clauses {
            $$.column_list= NEW_PTN PT_item_list(POS()); 
            $$.insert_query_expression= $1;
          }
|'(' ')' query_expression_with_opt_locking_clauses {
            $$.column_list= NEW_PTN PT_item_list(POS()); 
            $$.insert_query_expression= $3;
          }
|'(' insert_columns ')' query_expression_with_opt_locking_clauses {
            $$.column_list= $2;
            $$.insert_query_expression= $4;
          }
;

insert_columns:
insert_columns ',' insert_column {
            if ($$->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
            $$->m_pos = @$;
          }
|insert_column {
            $$= NEW_PTN PT_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
;

insert_values:
value_or_values values_list {
            $$= $2;
          }
;

query_expression_with_opt_locking_clauses:
query_expression { $$ = $1; }
|query_expression locking_clause_list {
            $$ = NEW_PTN PT_locking(@$, $1, $2);
          }
;

value_or_values:
VALUE_SYM 
|VALUES 
;

values_list:
values_list ',' row_value {
            if ($$->push_back(&$3->value))
              MYSQL_YYABORT;
            $$->m_pos = @$;
          }
|row_value {
            $$= NEW_PTN PT_insert_values_list(@$, YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back(&$1->value))
              MYSQL_YYABORT;
          }
;

values_row_list:
values_row_list ',' row_value_explicit {
            if ($$->push_back(&$3->value))
              MYSQL_YYABORT;
            $$->m_pos = @$;
          }
|row_value_explicit {
            $$= NEW_PTN PT_insert_values_list(@$, YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back(&$1->value))
              MYSQL_YYABORT;
          }
;

equal:
EQ 
|SET_VAR 
;

opt_equal:
%empty 
|equal 
;

row_value:
'(' opt_values ')' { $$= $2; }
;

row_value_explicit:
ROW_SYM '(' opt_values ')' { $$= $3; }
;

opt_values:
%empty {
            $$= NEW_PTN PT_item_list(POS());
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|values 
;

values:
values ',' expr_or_default {
            if ($1->push_back($3))
              MYSQL_YYABORT;
            $$= $1;
            $$->m_pos = @$;
          }
|expr_or_default {
            $$= NEW_PTN PT_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
;

expr_or_default:
expr 
|DEFAULT_SYM {
            $$= NEW_PTN Item_default_value(@$);
          }
;

opt_values_reference:
%empty {
            $$.table_alias = NULL_CSTR;
            $$.column_list = nullptr;
          }
|AS ident opt_derived_column_list {
            $$.table_alias = to_lex_cstring($2);
            
            void *column_list_raw_mem= YYTHD->memdup(&($3), sizeof($3));
            if (!column_list_raw_mem)
              MYSQL_YYABORT; 
            $$.column_list =
              static_cast<Create_col_name_list *>(column_list_raw_mem);
          }
;

opt_insert_update_list:
%empty {
            $$.value_list= nullptr;
            $$.column_list= nullptr;
          }
|ON_SYM DUPLICATE_SYM KEY_SYM UPDATE_SYM update_list {
            $$= $5;
          }
;

update_stmt:
opt_with_clause UPDATE_SYM opt_low_priority opt_ignore table_reference_list SET_SYM update_list opt_where_clause opt_order_clause opt_simple_limit {
            $$= NEW_PTN PT_update(@$, $1, $2, $3, $4, $5, $7.column_list, $7.value_list,
                                  $8, $9, $10);
          }
;

opt_with_clause:
%empty { $$= nullptr; }
|with_clause { $$= $1; }
;

update_list:
update_list ',' update_elem {
            $$= $1;
            if ($$.column_list->push_back($3.column) ||
                $$.value_list->push_back($3.value))
              MYSQL_YYABORT; 
          }
|update_elem {
            $$.column_list= NEW_PTN PT_item_list(@$);
            $$.value_list= NEW_PTN PT_item_list(@$);
            if ($$.column_list == nullptr || $$.value_list == nullptr ||
                $$.column_list->push_back($1.column) ||
                $$.value_list->push_back($1.value))
              MYSQL_YYABORT; 
          }
;

update_elem:
simple_ident_nospvar equal expr_or_default {
            $$.column= $1;
            $$.value= $3;
          }
;

opt_low_priority:
%empty { $$= TL_WRITE_DEFAULT; }
|LOW_PRIORITY { $$= TL_WRITE_LOW_PRIORITY; }
;

delete_stmt:
opt_with_clause DELETE_SYM opt_delete_options FROM table_ident opt_table_alias opt_use_partition opt_where_clause opt_order_clause opt_simple_limit {
            $$= NEW_PTN PT_delete(@$, $1, $2, $3, $5, $6, $7, $8, $9, $10);
          }
|opt_with_clause DELETE_SYM opt_delete_options table_alias_ref_list FROM table_reference_list opt_where_clause {
            $$= NEW_PTN PT_delete(@$, $1, $2, $3, $4, $6, $7);
          }
|opt_with_clause DELETE_SYM opt_delete_options FROM table_alias_ref_list USING table_reference_list opt_where_clause {
            $$= NEW_PTN PT_delete(@$, $1, $2, $3, $5, $7, $8);
          }
;

opt_wild:
%empty 
|'.' '*' 
;

opt_delete_options:
%empty { $$= 0; }
|opt_delete_option opt_delete_options { $$= $1 | $2; }
;

opt_delete_option:
QUICK { $$= DELETE_QUICK; }
|LOW_PRIORITY { $$= DELETE_LOW_PRIORITY; }
|IGNORE_SYM { $$= DELETE_IGNORE; }
;

truncate_stmt:
TRUNCATE_SYM opt_table table_ident {
            $$= NEW_PTN PT_truncate_table_stmt(@$, $3);
          }
;

opt_table:
%empty 
|TABLE_SYM 
;

opt_profile_defs:
%empty { $$ = 0; }
|profile_defs 
;

profile_defs:
profile_def 
|profile_defs ',' profile_def { $$ = $1 | $3; }
;

profile_def:
CPU_SYM { $$ = PROFILE_CPU; }
|MEMORY_SYM { $$ = PROFILE_MEMORY; }
|BLOCK_SYM IO_SYM { $$ = PROFILE_BLOCK_IO; }
|CONTEXT_SYM SWITCHES_SYM { $$ = PROFILE_CONTEXT; }
|PAGE_SYM FAULTS_SYM { $$ = PROFILE_PAGE_FAULTS; }
|IPC_SYM { $$ = PROFILE_IPC; }
|SWAPS_SYM { $$ = PROFILE_SWAPS; }
|SOURCE_SYM { $$ = PROFILE_SOURCE; }
|ALL { $$ = PROFILE_ALL; }
;

opt_for_query:
%empty { $$ = 0; }
|FOR_SYM QUERY_SYM NUM {
            int error;
            $$ = static_cast<my_thread_id>(my_strtoll10($3.str, nullptr, &error));
            if (error != 0)
              MYSQL_YYABORT;
          }
;

show_databases_stmt:
SHOW DATABASES opt_wild_or_where {
             $$ = NEW_PTN PT_show_databases(@$, $3.wild, $3.where);
           }

show_tables_stmt:
SHOW opt_show_cmd_type TABLES opt_db opt_wild_or_where {
            $$ = NEW_PTN PT_show_tables(@$, $2, $4, $5.wild, $5.where);
          }
;

show_triggers_stmt:
SHOW opt_full TRIGGERS_SYM opt_db opt_wild_or_where {
            $$ = NEW_PTN PT_show_triggers(@$, $2, $4, $5.wild, $5.where);
          }
;

show_events_stmt:
SHOW EVENTS_SYM opt_db opt_wild_or_where {
            $$ = NEW_PTN PT_show_events(@$, $3, $4.wild, $4.where);
          }
;

show_table_status_stmt:
SHOW TABLE_SYM STATUS_SYM opt_db opt_wild_or_where {
            $$ = NEW_PTN PT_show_table_status(@$, $4, $5.wild, $5.where);
          }
;

show_open_tables_stmt:
SHOW OPEN_SYM TABLES opt_db opt_wild_or_where {
             $$ = NEW_PTN PT_show_open_tables(@$, $4, $5.wild, $5.where);
          }
;

show_plugins_stmt:
SHOW PLUGINS_SYM {
            $$ = NEW_PTN PT_show_plugins(@$);
          }
;

show_engine_logs_stmt:
SHOW ENGINE_SYM engine_or_all LOGS_SYM {
            $$ = NEW_PTN PT_show_engine_logs(@$, $3);
          }
;

show_engine_mutex_stmt:
SHOW ENGINE_SYM engine_or_all MUTEX_SYM {
            $$ = NEW_PTN PT_show_engine_mutex(@$, $3);
          }
;

show_engine_status_stmt:
SHOW ENGINE_SYM engine_or_all STATUS_SYM {
            $$ = NEW_PTN PT_show_engine_status(@$, $3);
          }
;

show_columns_stmt:
SHOW opt_show_cmd_type COLUMNS from_or_in table_ident opt_db opt_wild_or_where {
            
            if ($6)
              $5->change_db($6);

            $$ = NEW_PTN PT_show_fields(@$, $2, $5, $7.wild, $7.where);
          }
;

show_binary_logs_stmt:
SHOW BINARY_SYM LOGS_SYM {
            $$ = NEW_PTN PT_show_binlogs(@$);
          }
;

show_replicas_stmt:
SHOW REPLICAS_SYM {
            $$ = NEW_PTN PT_show_replicas(@$);
          }
;

show_binlog_events_stmt:
SHOW BINLOG_SYM EVENTS_SYM opt_binlog_in binlog_from opt_limit_clause {
            $$ = NEW_PTN PT_show_binlog_events(@$, $4, $6);
          }
;

show_relaylog_events_stmt:
SHOW RELAYLOG_SYM EVENTS_SYM opt_binlog_in binlog_from opt_limit_clause opt_channel {
            $$ = NEW_PTN PT_show_relaylog_events(@$, $4, $6, $7);
          }
;

show_keys_stmt:
SHOW opt_extended keys_or_index from_or_in table_ident opt_db opt_where_clause {
            
            if ($6)
              $5->change_db($6);

            $$ = NEW_PTN PT_show_keys(@$, $2, $5, $7);
          }
;

show_engines_stmt:
SHOW opt_storage ENGINES_SYM {
            $$ = NEW_PTN PT_show_engines(@$);
          }
;

show_count_warnings_stmt:
SHOW COUNT_SYM '(' '*' ')' WARNINGS {
            $$ = NEW_PTN PT_show_count_warnings(@$);
          }
;

show_count_errors_stmt:
SHOW COUNT_SYM '(' '*' ')' ERRORS {
            $$ = NEW_PTN PT_show_count_errors(@$);
          }
;

show_warnings_stmt:
SHOW WARNINGS opt_limit_clause {
            $$ = NEW_PTN PT_show_warnings(@$, $3);
          }
;

show_errors_stmt:
SHOW ERRORS opt_limit_clause {
            $$ = NEW_PTN PT_show_errors(@$, $3);
          }
;

show_profiles_stmt:
SHOW PROFILES_SYM {
            push_warning_printf(YYTHD, Sql_condition::SL_WARNING,
                                ER_WARN_DEPRECATED_SYNTAX,
                                ER_THD(YYTHD, ER_WARN_DEPRECATED_SYNTAX),
                                "SHOW PROFILES", "Performance Schema");
            $$ = NEW_PTN PT_show_profiles(@$);
          }
;

show_profile_stmt:
SHOW PROFILE_SYM opt_profile_defs opt_for_query opt_limit_clause {
            $$ = NEW_PTN PT_show_profile(@$, $3, $4, $5);
          }
;

show_status_stmt:
SHOW opt_var_type STATUS_SYM opt_wild_or_where {
             $$ = NEW_PTN PT_show_status(@$, $2, $4.wild, $4.where);
          }
;

show_processlist_stmt:
SHOW opt_full PROCESSLIST_SYM {
            $$ = NEW_PTN PT_show_processlist(@$, $2);
          }
;

show_variables_stmt:
SHOW opt_var_type VARIABLES opt_wild_or_where {
            $$ = NEW_PTN PT_show_variables(@$, $2, $4.wild, $4.where);
          }
;

show_character_set_stmt:
SHOW character_set opt_wild_or_where {
            $$ = NEW_PTN PT_show_charsets(@$, $3.wild, $3.where);
          }
;

show_collation_stmt:
SHOW COLLATION_SYM opt_wild_or_where {
            $$ = NEW_PTN PT_show_collations(@$, $3.wild, $3.where);
          }
;

show_privileges_stmt:
SHOW PRIVILEGES {
            $$ = NEW_PTN PT_show_privileges(@$);
          }
;

show_grants_stmt:
SHOW GRANTS {
            $$ = NEW_PTN PT_show_grants(@$, nullptr, nullptr);
          }
|SHOW GRANTS FOR_SYM user {
            $$ = NEW_PTN PT_show_grants(@$, $4, nullptr);
          }
|SHOW GRANTS FOR_SYM user USING user_list {
            $$ = NEW_PTN PT_show_grants(@$, $4, $6);
          }
;

show_create_database_stmt:
SHOW CREATE DATABASE opt_if_not_exists ident {
            $$ = NEW_PTN PT_show_create_database(@$, $4, $5);
          }
;

show_create_table_stmt:
SHOW CREATE TABLE_SYM table_ident {
            $$ = NEW_PTN PT_show_create_table(@$, $4);
          }
;

show_create_view_stmt:
SHOW CREATE VIEW_SYM table_ident {
            $$ = NEW_PTN PT_show_create_view(@$, $4);
          }
;

show_binary_log_status_stmt:
SHOW BINARY_SYM LOG_SYM STATUS_SYM {
            $$ = NEW_PTN PT_show_binary_log_status(@$);
          }
;

show_replica_status_stmt:
SHOW REPLICA_SYM STATUS_SYM opt_channel {
            $$ = NEW_PTN PT_show_replica_status(@$, $4);
          }
;

show_create_procedure_stmt:
SHOW CREATE PROCEDURE_SYM sp_name {
            $$ = NEW_PTN PT_show_create_procedure(@$, $4);
          }
;

show_create_function_stmt:
SHOW CREATE FUNCTION_SYM sp_name {
            $$ = NEW_PTN PT_show_create_function(@$, $4);
          }
;

show_create_trigger_stmt:
SHOW CREATE TRIGGER_SYM sp_name {
            $$ = NEW_PTN PT_show_create_trigger(@$, $4);
          }
;

show_procedure_status_stmt:
SHOW PROCEDURE_SYM STATUS_SYM opt_wild_or_where {
            $$ = NEW_PTN PT_show_status_proc(@$, $4.wild, $4.where);
          }
;

show_function_status_stmt:
SHOW FUNCTION_SYM STATUS_SYM opt_wild_or_where {
            $$ = NEW_PTN PT_show_status_func(@$, $4.wild, $4.where);
          }
;

show_procedure_code_stmt:
SHOW PROCEDURE_SYM CODE_SYM sp_name {
            $$ = NEW_PTN PT_show_procedure_code(@$, $4);
          }
;

show_function_code_stmt:
SHOW FUNCTION_SYM CODE_SYM sp_name {
            $$ = NEW_PTN PT_show_function_code(@$, $4);
          }
;

show_create_event_stmt:
SHOW CREATE EVENT_SYM sp_name {
            $$ = NEW_PTN PT_show_create_event(@$, $4);
          }
;

show_create_user_stmt:
SHOW CREATE USER user {
            $$ = NEW_PTN PT_show_create_user(@$, $4);
          }
;

show_parse_tree_stmt:
SHOW PARSE_TREE_SYM simple_statement {
#ifndef WITH_SHOW_PARSE_TREE
            YYTHD->syntax_error_at(@2);
            MYSQL_YYABORT;
#endif
            $$ = NEW_PTN PT_show_parse_tree(@$, $3);
          }
;

engine_or_all:
ident_or_text 
|ALL { $$ = {}; }
;

opt_storage:
%empty 
|STORAGE_SYM 
;

opt_db:
%empty { $$= nullptr; }
|from_or_in ident { $$= $2.str; }
;

opt_full:
%empty { $$= 0; }
|FULL { $$= 1; }
;

opt_extended:
%empty { $$= 0; }
|EXTENDED_SYM { $$= 1; }
;

opt_show_cmd_type:
%empty { $$= Show_cmd_type::STANDARD; }
|FULL { $$= Show_cmd_type::FULL_SHOW; }
|EXTENDED_SYM { $$= Show_cmd_type::EXTENDED_SHOW; }
|EXTENDED_SYM FULL { $$= Show_cmd_type::EXTENDED_FULL_SHOW; }
;

from_or_in:
FROM 
|IN_SYM 
;

opt_binlog_in:
%empty { $$ = {}; }
|IN_SYM TEXT_STRING_sys { $$ = $2; }
;

binlog_from:
%empty { Lex->mi.pos = 4;  }
|FROM ulonglong_num { Lex->mi.pos = $2; }
;

opt_wild_or_where:
%empty { $$ = {}; }
|LIKE TEXT_STRING_literal { $$ = { $2, {} }; }
|where_clause { $$ = { {}, $1 }; }
;

describe_stmt:
describe_command table_ident opt_describe_column {
            $$= NEW_PTN PT_show_fields(@$, Show_cmd_type::STANDARD, $2, $3);
          }
;

explain_stmt:
describe_command opt_explain_options explainable_stmt {
            $$= NEW_PTN PT_explain(@$, $2.explain_format_type, $2.is_analyze,
                  $2.is_explicit, $3.statement,
                  $2.explain_into_variable_name.length ?
                  std::optional<std::string_view>(
                    to_string_view($2.explain_into_variable_name)) :
                  std::optional<std::string_view>(std::nullopt),
                  $3.schema_name_for_explain);
          }
;

explainable_stmt:
opt_explain_for_schema select_stmt {
            $$.statement = $2;
            $$.schema_name_for_explain = $1;
          }
|opt_explain_for_schema insert_stmt {
            $$.statement = $2;
            $$.schema_name_for_explain = $1;
          }
|opt_explain_for_schema replace_stmt {
            $$.statement = $2;
            $$.schema_name_for_explain = $1;
          }
|opt_explain_for_schema update_stmt {
            $$.statement = $2;
            $$.schema_name_for_explain = $1;
          }
|opt_explain_for_schema delete_stmt {
            $$.statement = $2;
            $$.schema_name_for_explain = $1;
          }
|FOR_SYM CONNECTION_SYM real_ulong_num {
            $$.statement = NEW_PTN PT_explain_for_connection(@$, static_cast<my_thread_id>($3));
            $$.schema_name_for_explain = NULL_CSTR;
          }
;

describe_command:
DESC 
|DESCRIBE 
;

opt_explain_format:
%empty {
            $$.is_explicit = false;
            $$.explain_format_type = YYTHD->variables.explain_format;
          }
|FORMAT_SYM EQ ident_or_text {
            $$.is_explicit = true;
            if (is_identifier($3, "JSON"))
              $$.explain_format_type = Explain_format_type::JSON;
            else if (is_identifier($3, "TRADITIONAL"))
              $$.explain_format_type = Explain_format_type::TRADITIONAL;
            else if (is_identifier($3, "TREE"))
              $$.explain_format_type = Explain_format_type::TREE;
            else {
              
              
              
              
              my_error(ER_UNKNOWN_EXPLAIN_FORMAT, MYF(0), $3.str);
              MYSQL_YYABORT;
            }
          }
;

opt_explain_options:
ANALYZE_SYM opt_explain_format {
            $$ = $2;
            $$.is_analyze = true;
            $$.explain_into_variable_name = NULL_STR;
          }
|opt_explain_format opt_explain_into {
            $$ = $1;
            $$.is_analyze = false;

            if ($2.length) {
              if (!$$.is_explicit) {
                MYSQL_YYABORT_ERROR(
                  ER_EXPLAIN_INTO_IMPLICIT_FORMAT_NOT_SUPPORTED, MYF(0));
              }
              if ($$.explain_format_type != Explain_format_type::JSON) {
                if ($$.explain_format_type == Explain_format_type::TREE) {
                  MYSQL_YYABORT_ERROR(ER_EXPLAIN_INTO_FORMAT_NOT_SUPPORTED,
                                      MYF(0), "TREE");
                } else {
                  MYSQL_YYABORT_ERROR(ER_EXPLAIN_INTO_FORMAT_NOT_SUPPORTED,
                                      MYF(0), "TRADITIONAL");
                }
              }
            }
            $$.explain_into_variable_name = $2;
          }
;

opt_explain_into:
%empty {
            $$ = NULL_STR;
          }
|INTO '@' ident_or_text {
            $$ = $3;
          }
;

opt_explain_for_schema:
%empty {
            $$ = NULL_CSTR;
          }
|FOR_SYM DATABASE ident_or_text {
            $$ = to_lex_cstring($3);
          }
;

opt_describe_column:
%empty { $$= LEX_STRING{ nullptr, 0 }; }
|text_string {
            if ($1 != nullptr)
              $$= $1->lex_string();
          }
|ident 
;

flush:
FLUSH_SYM opt_no_write_to_binlog {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_FLUSH;
            lex->type= 0;
            lex->no_write_to_binlog= $2;
          }flush_options {}
;

flush_options:
table_or_tables opt_table_list {
            Lex->type|= REFRESH_TABLES;
            
            YYPS->m_lock_type= TL_READ_NO_INSERT;
            YYPS->m_mdl_type= MDL_SHARED_HIGH_PRIO;
            if (Select->add_tables(YYTHD, $2, TL_OPTION_UPDATING,
                                   YYPS->m_lock_type, YYPS->m_mdl_type))
              MYSQL_YYABORT;
          }opt_flush_lock {}
|flush_options_list 
;

opt_flush_lock:
%empty {}
|WITH READ_SYM LOCK_SYM {
            Table_ref *tables= Lex->query_tables;
            Lex->type|= REFRESH_READ_LOCK;
            for (; tables; tables= tables->next_global)
            {
              tables->mdl_request.set_type(MDL_SHARED_NO_WRITE);
              
              tables->required_type= dd::enum_table_type::BASE_TABLE;
              tables->open_type= OT_BASE_ONLY;      
            }
          }
|FOR_SYM {
            if (Lex->query_tables == nullptr) 
            {
              YYTHD->syntax_error(ER_NO_TABLES_USED);
              MYSQL_YYABORT;
            }
          }EXPORT_SYM {
            Table_ref *tables= Lex->query_tables;
            Lex->type|= REFRESH_FOR_EXPORT;
            for (; tables; tables= tables->next_global)
            {
              tables->mdl_request.set_type(MDL_SHARED_NO_WRITE);
              
              tables->required_type= dd::enum_table_type::BASE_TABLE;
              tables->open_type= OT_BASE_ONLY;      
            }
          }
;

flush_options_list:
flush_options_list ',' flush_option 
|flush_option {}
;

flush_option:
ERROR_SYM LOGS_SYM { Lex->type|= REFRESH_ERROR_LOG; }
|ENGINE_SYM LOGS_SYM { Lex->type|= REFRESH_ENGINE_LOG; }
|GENERAL LOGS_SYM { Lex->type|= REFRESH_GENERAL_LOG; }
|SLOW LOGS_SYM { Lex->type|= REFRESH_SLOW_LOG; }
|BINARY_SYM LOGS_SYM { Lex->type|= REFRESH_BINARY_LOG; }
|RELAY LOGS_SYM opt_channel {
            Lex->type|= REFRESH_RELAY_LOG;
            if (Lex->set_channel_name($3))
              MYSQL_YYABORT;  
          }
|PRIVILEGES { Lex->type|= REFRESH_GRANT; }
|LOGS_SYM { Lex->type|= REFRESH_LOG; }
|STATUS_SYM { Lex->type|= REFRESH_STATUS; }
|RESOURCES { Lex->type|= REFRESH_USER_RESOURCES; }
|OPTIMIZER_COSTS_SYM { Lex->type|= REFRESH_OPTIMIZER_COSTS; }
;

opt_table_list:
%empty { $$= nullptr; }
|table_list 
;

reset:
RESET_SYM {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_RESET; lex->type=0;
          }reset_options {}
|RESET_SYM PERSIST_SYM opt_if_exists_ident {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_RESET;
            lex->type|= REFRESH_PERSIST;
            lex->option_type= OPT_PERSIST;
          }
;

reset_options:
reset_options ',' reset_option 
|reset_option 
;

opt_if_exists_ident:
%empty {
            LEX *lex=Lex;
            lex->drop_if_exists= false;
            lex->name= NULL_STR;
          }
|if_exists persisted_variable_ident {
            LEX *lex=Lex;
            lex->drop_if_exists= $1;
            lex->name= $2;
          }
;

persisted_variable_ident:
ident 
|ident '.' ident {
            const LEX_STRING prefix = $1;
            const LEX_STRING suffix = $3;
            $$.length = prefix.length + 1 + suffix.length + 1;
            $$.str = static_cast<char *>(YYTHD->alloc($$.length));
            if ($$.str == nullptr) YYABORT;  
            strxnmov($$.str, $$.length, prefix.str, ".", suffix.str, nullptr);
          }
|DEFAULT_SYM '.' ident {
            const LEX_CSTRING prefix{STRING_WITH_LEN("default")};
            const LEX_STRING suffix = $3;
            $$.length = prefix.length + 1 + suffix.length + 1;
            $$.str = static_cast<char *>(YYTHD->alloc($$.length));
            if ($$.str == nullptr) YYABORT;  
            strxnmov($$.str, $$.length, prefix.str, ".", suffix.str, nullptr);
          }
;

reset_option:
REPLICA_SYM { Lex->type|= REFRESH_REPLICA; }opt_replica_reset_options opt_channel {
          if (Lex->set_channel_name($4))
            MYSQL_YYABORT;  
          }
|BINARY_SYM LOGS_SYM AND_SYM GTIDS_SYM {
            Lex->type|= REFRESH_SOURCE;
            
            if (!(YYTHD)->global_read_lock.is_acquired())
              Lex->type|= REFRESH_TABLES | REFRESH_READ_LOCK;
          }source_reset_options 
;

opt_replica_reset_options:
%empty { Lex->reset_replica_info.all= false; }
|ALL { Lex->reset_replica_info.all= true; }
;

source_reset_options:
%empty {}
|TO_SYM real_ulonglong_num {
            if ($2 == 0 || $2 > MAX_ALLOWED_FN_EXT_RESET_BIN_LOGS)
            {
              my_error(ER_RESET_SOURCE_TO_VALUE_OUT_OF_RANGE, MYF(0),
                       $2, MAX_ALLOWED_FN_EXT_RESET_BIN_LOGS);
              MYSQL_YYABORT;
            }
            else
              Lex->next_binlog_file_nr = $2;
          }
;

purge:
PURGE {
            LEX *lex=Lex;
            lex->type=0;
            lex->sql_command = SQLCOM_PURGE;
          }purge_options {}
;

purge_options:
BINARY_SYM LOGS_SYM purge_option 
;

purge_option:
TO_SYM TEXT_STRING_sys {
            Lex->to_log = $2.str;
          }
|BEFORE_SYM expr {
            ITEMIZE($2, &$2);

            LEX *lex= Lex;
            lex->purge_value_list.clear();
            lex->purge_value_list.push_front($2);
            lex->sql_command= SQLCOM_PURGE_BEFORE;
          }
;

kill:
KILL_SYM kill_option expr {
            ITEMIZE($3, &$3);

            LEX *lex=Lex;
            lex->kill_value_list.clear();
            lex->kill_value_list.push_front($3);
            lex->sql_command= SQLCOM_KILL;
          }
;

kill_option:
%empty { Lex->type= 0; }
|CONNECTION_SYM { Lex->type= 0; }
|QUERY_SYM { Lex->type= ONLY_KILL_QUERY; }
;

use:
USE_SYM ident {
            LEX *lex=Lex;
            if (lex->sphead) {
              my_error(ER_SP_BADSTATEMENT, MYF(0), "USE");
              MYSQL_YYABORT;
            }
            lex->sql_command=SQLCOM_CHANGE_DB;
            lex->query_block->db= $2.str;
          }
;

load_stmt:
LOAD data_or_xml load_data_lock opt_from_keyword opt_local load_source_type TEXT_STRING_filesystem opt_source_count opt_source_order opt_duplicate INTO TABLE_SYM table_ident opt_use_partition opt_load_data_charset opt_compression_algorithm opt_xml_rows_identified_by opt_field_term opt_line_term opt_ignore_lines opt_field_or_var_spec opt_load_data_set_spec opt_load_parallel opt_load_memory opt_load_algorithm {
            $$= NEW_PTN PT_load_table(@$, $2,  
                                      $3,  
                                      $5,  
                                      $6,  
                                      $7,  
                                      $8,  
                                      $9,  
                                      $10, 
                                      $13, 
                                      $14, 
                                      $15, 
                                      $16, 
                                      $17, 
                                      $18, 
                                      $19, 
                                      $20, 
                                      $21, 
                                      $22.set_var_list,
                                      $22.set_expr_list,
                                      $22.set_expr_str_list,
                                      $23,  
                                      $24,  
                                      $25); 
          }
;

data_or_xml:
DATA_SYM { $$= FILETYPE_CSV; }
|XML_SYM { $$= FILETYPE_XML; }
;

opt_local:
%empty { $$= false; }
|LOCAL_SYM { $$= true; }
;

opt_from_keyword:
%empty {}
|FROM {}
;

load_data_lock:
%empty { $$= TL_WRITE_DEFAULT; }
|CONCURRENT { $$= TL_WRITE_CONCURRENT_INSERT; }
|LOW_PRIORITY { $$= TL_WRITE_LOW_PRIORITY; }
;

load_source_type:
INFILE_SYM { $$ = LOAD_SOURCE_FILE; }
|URL_SYM { $$ = LOAD_SOURCE_URL; }
|S3_SYM { $$ = LOAD_SOURCE_S3; }
;

opt_source_count:
%empty { $$= 0; }
|IDENT_sys NUM {
            const long n_files= atol($2.str);
            
            if (my_strcasecmp(system_charset_info, $1.str, "count") != 0) {
              YYTHD->syntax_error_at(@1, "COUNT expected");
              YYABORT;
            }
            if (n_files == 0) {
              YYTHD->syntax_error_at(@2, "The number of files cannot be zero");
              MYSQL_YYABORT;
            }
            $$= n_files;
          }
;

opt_source_order:
%empty { $$= false; }
|IN_SYM PRIMARY_SYM KEY_SYM ORDER_SYM { $$= true; }
;

opt_duplicate:
%empty { $$= On_duplicate::ERROR; }
|duplicate 
;

duplicate:
REPLACE_SYM { $$= On_duplicate::REPLACE_DUP; }
|IGNORE_SYM { $$= On_duplicate::IGNORE_DUP; }
;

opt_field_term:
%empty { $$.cleanup(); }
|COLUMNS field_term_list { $$= $2; }
;

field_term_list:
field_term_list field_term {
            $$= $1;
            $$.merge_field_separators($2);
          }
|field_term 
;

field_term:
TERMINATED BY text_string {
            $$.cleanup();
            $$.field_term= $3;
          }
|OPTIONALLY ENCLOSED BY text_string {
            $$.cleanup();
            $$.enclosed= $4;
            $$.opt_enclosed= 1;
          }
|ENCLOSED BY text_string {
            $$.cleanup();
            $$.enclosed= $3;
          }
|ESCAPED BY text_string {
            $$.cleanup();
            $$.escaped= $3;
          }
;

opt_line_term:
%empty { $$.cleanup(); }
|LINES line_term_list { $$= $2; }
;

line_term_list:
line_term_list line_term {
            $$= $1;
            $$.merge_line_separators($2);
          }
|line_term 
;

line_term:
TERMINATED BY text_string {
            $$.cleanup();
            $$.line_term= $3;
          }
|STARTING BY text_string {
            $$.cleanup();
            $$.line_start= $3;
          }
;

opt_xml_rows_identified_by:
%empty { $$= nullptr; }
|ROWS_SYM IDENTIFIED_SYM BY text_string { $$= $4; }
;

opt_ignore_lines:
%empty { $$= 0; }
|IGNORE_SYM NUM lines_or_rows { $$= atol($2.str); }
;

lines_or_rows:
LINES 
|ROWS_SYM 
;

opt_field_or_var_spec:
%empty { $$= nullptr; }
|'(' fields_or_vars ')' { $$= $2; }
|'(' ')' { $$= nullptr; }
;

fields_or_vars:
fields_or_vars ',' field_or_var {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
            $$->m_pos = @$;
          }
|field_or_var {
            $$= NEW_PTN PT_item_list(@$);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
;

field_or_var:
simple_ident_nospvar 
|'@' ident_or_text {
            $$= NEW_PTN Item_user_var_as_out_param(@$, $2);
          }
;

opt_load_data_set_spec:
%empty { $$= {nullptr, nullptr, nullptr}; }
|SET_SYM load_data_set_list { $$= $2; }
;

load_data_set_list:
load_data_set_list ',' load_data_set_elem {
            $$= $1;
            if ($$.set_var_list->push_back($3.set_var) ||
                $$.set_expr_list->push_back($3.set_expr) ||
                $$.set_expr_str_list->push_back($3.set_expr_str))
              MYSQL_YYABORT; 
          }
|load_data_set_elem {
            $$.set_var_list= NEW_PTN PT_item_list(@$);
            if ($$.set_var_list == nullptr ||
                $$.set_var_list->push_back($1.set_var))
              MYSQL_YYABORT; 

            $$.set_expr_list= NEW_PTN PT_item_list(@$);
            if ($$.set_expr_list == nullptr ||
                $$.set_expr_list->push_back($1.set_expr))
              MYSQL_YYABORT; 

            $$.set_expr_str_list= NEW_PTN List<String>;
            if ($$.set_expr_str_list == nullptr ||
                $$.set_expr_str_list->push_back($1.set_expr_str))
              MYSQL_YYABORT; 
          }
;

load_data_set_elem:
simple_ident_nospvar equal expr_or_default {
            size_t length= @3.cpp.end - @2.cpp.start;

            if ($3 == nullptr)
              MYSQL_YYABORT; 
            $3->item_name.copy(@2.cpp.start, length, YYTHD->charset());

            $$.set_var= $1;
            $$.set_expr= $3;
            $$.set_expr_str= NEW_PTN String(@2.cpp.start,
                                            length,
                                            YYTHD->charset());
            if ($$.set_expr_str == nullptr)
              MYSQL_YYABORT; 
          }
;

opt_load_algorithm:
%empty { $$ = false; }
|ALGORITHM_SYM EQ BULK_SYM { $$ = true; }
;

opt_compression_algorithm:
%empty { $$ = {}; }
|COMPRESSION_SYM EQ TEXT_STRING_sys { $$ = to_lex_cstring($3); }
;

opt_load_parallel:
%empty { $$ = 0; }
|PARALLEL_SYM EQ NUM { $$= atol($3.str); }
;

opt_load_memory:
%empty { $$ = 0; }
|MEMORY_SYM EQ size_number { $$ = $3; }
;

text_literal:
TEXT_STRING {
            $$= NEW_PTN PTI_text_literal_text_string(@$,
                YYTHD->m_parser_state->m_lip.text_string_is_7bit(), $1);
          }
|NCHAR_STRING {
            $$= NEW_PTN PTI_text_literal_nchar_string(@$,
                YYTHD->m_parser_state->m_lip.text_string_is_7bit(), $1);
            warn_about_deprecated_national(YYTHD);
          }
|UNDERSCORE_CHARSET TEXT_STRING {
            $$= NEW_PTN PTI_text_literal_underscore_charset(@$,
                YYTHD->m_parser_state->m_lip.text_string_is_7bit(), $1, $2);
          }
|text_literal TEXT_STRING_literal {
            $$= NEW_PTN PTI_text_literal_concat(@$,
                YYTHD->m_parser_state->m_lip.text_string_is_7bit(), $1, $2);
          }
;

text_string:
TEXT_STRING_literal {
            $$= NEW_PTN String($1.str, $1.length,
                               YYTHD->variables.collation_connection);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|HEX_NUM {
            LEX_CSTRING s= Item_hex_string::make_hex_str($1.str, $1.length);
            $$= NEW_PTN String(s.str, s.length, &my_charset_bin);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|BIN_NUM {
            LEX_CSTRING s= Item_bin_string::make_bin_str($1.str, $1.length);
            $$= NEW_PTN String(s.str, s.length, &my_charset_bin);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

param_marker:
PARAM_MARKER {
            auto *i= NEW_PTN Item_param(@$, YYMEM_ROOT,
                                        (uint) (@1.raw.start - YYLIP->get_buf()));
            if (i == nullptr)
              MYSQL_YYABORT;
            auto *lex= Lex;
            
            if (!lex->reparse_common_table_expr_at &&
                lex->param_list.push_back(i))
              MYSQL_YYABORT;
            $$= i;
          }
;

signed_literal:
literal 
|'+' NUM_literal { $$= $2; }
|'-' NUM_literal {
            if ($2 == nullptr)
              MYSQL_YYABORT; 
            $2->max_length++;
            $$= $2->neg();
          }
;

signed_literal_or_null:
signed_literal 
|null_as_literal 
;

null_as_literal:
NULL_SYM {
            Lex_input_stream *lip= YYLIP;
            
            lip->reduce_digest_token(TOK_GENERIC_VALUE, NULL_SYM);
            $$= NEW_PTN Item_null(@$);
          }
;

literal:
text_literal { $$= $1; }
|NUM_literal { $$= $1; }
|temporal_literal 
|FALSE_SYM {
            $$= NEW_PTN Item_func_false(@$);
          }
|TRUE_SYM {
            $$= NEW_PTN Item_func_true(@$);
          }
|HEX_NUM {
            $$= NEW_PTN Item_hex_string(@$, $1);
          }
|BIN_NUM {
            $$= NEW_PTN Item_bin_string(@$, $1);
          }
|UNDERSCORE_CHARSET HEX_NUM {
            $$= NEW_PTN PTI_literal_underscore_charset_hex_num(@$, $1, $2);
          }
|UNDERSCORE_CHARSET BIN_NUM {
            $$= NEW_PTN PTI_literal_underscore_charset_bin_num(@$, $1, $2);
          }
;

literal_or_null:
literal 
|null_as_literal 
;

NUM_literal:
int64_literal 
|DECIMAL_NUM {
            $$= NEW_PTN Item_decimal(@$, $1.str, $1.length, YYCSCL);
          }
|FLOAT_NUM {
            $$= NEW_PTN Item_float(@$, $1.str, $1.length);
          }
;

int64_literal:
NUM { $$ = NEW_PTN Item_int(@$, $1); }
|LONG_NUM { $$ = NEW_PTN Item_int(@$, $1); }
|ULONGLONG_NUM { $$ = NEW_PTN Item_uint(@$, $1.str, $1.length); }
;

temporal_literal:
DATE_SYM TEXT_STRING {
            $$= NEW_PTN PTI_temporal_literal(@$, $2, MYSQL_TYPE_DATE, YYCSCL);
          }
|TIME_SYM TEXT_STRING {
            $$= NEW_PTN PTI_temporal_literal(@$, $2, MYSQL_TYPE_TIME, YYCSCL);
          }
|TIMESTAMP_SYM TEXT_STRING {
            $$= NEW_PTN PTI_temporal_literal(@$, $2, MYSQL_TYPE_DATETIME, YYCSCL);
          }
;

opt_interval:
%empty { $$ = false; }
|INTERVAL_SYM { $$ = true; }
;

insert_column:
simple_ident_nospvar 
;

table_wild:
ident '.' '*' {
            $$ = NEW_PTN Item_asterisk(@$, nullptr, $1.str);
          }
|ident '.' ident '.' '*' {
            if (check_and_convert_db_name(&$1, false) != Ident_name_check::OK)
              MYSQL_YYABORT;
            auto schema_name = YYCLIENT_NO_SCHEMA ? nullptr : $1.str;
            $$ = NEW_PTN Item_asterisk(@$, schema_name, $3.str);
          }
;

order_expr:
expr opt_ordering_direction {
            $$= NEW_PTN PT_order_expr(@$, $1, $2);
          }
;

grouping_expr:
expr {
            $$= NEW_PTN PT_order_expr(@$, $1, ORDER_NOT_RELEVANT);
          }
;

simple_ident:
ident {
            $$= NEW_PTN PTI_simple_ident_ident(@$, to_lex_cstring($1));
          }
|simple_ident_q 
;

simple_ident_nospvar:
ident {
            $$= NEW_PTN PTI_simple_ident_nospvar_ident(@$, $1);
          }
|simple_ident_q 
;

simple_ident_q:
ident '.' ident {
            $$= NEW_PTN PTI_simple_ident_q_2d(@$, $1.str, $3.str);
          }
|ident '.' ident '.' ident {
            if (check_and_convert_db_name(&$1, false) != Ident_name_check::OK)
              MYSQL_YYABORT;
            $$= NEW_PTN PTI_simple_ident_q_3d(@$, $1.str, $3.str, $5.str);
          }
;

table_ident:
ident {
            $$= NEW_PTN Table_ident(to_lex_cstring($1));
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|ident '.' ident {
            auto schema_name = YYCLIENT_NO_SCHEMA ? LEX_CSTRING{}
                                                  : to_lex_cstring($1.str);
            $$= NEW_PTN Table_ident(schema_name, to_lex_cstring($3));
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

table_ident_opt_wild:
ident opt_wild {
            $$= NEW_PTN Table_ident(to_lex_cstring($1));
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|ident '.' ident opt_wild {
            $$= NEW_PTN Table_ident(YYTHD->get_protocol(),
                                    to_lex_cstring($1),
                                    to_lex_cstring($3), 0);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
;

IDENT_sys:
IDENT { $$= $1; }
|IDENT_QUOTED {
            THD *thd= YYTHD;

            if (thd->charset_is_system_charset)
            {
              const CHARSET_INFO *cs= system_charset_info;
              int dummy_error;
              size_t wlen= cs->cset->well_formed_len(cs, $1.str,
                                                     $1.str+$1.length,
                                                     $1.length, &dummy_error);
              if (wlen < $1.length)
              {
                ErrConvString err($1.str, $1.length, &my_charset_bin);
                my_error(ER_INVALID_CHARACTER_STRING, MYF(0),
                         cs->csname, err.ptr());
                MYSQL_YYABORT;
              }
              $$= $1;
            }
            else
            {
              if (thd->convert_string(&$$, system_charset_info,
                                  $1.str, $1.length, thd->charset()))
                MYSQL_YYABORT;
            }
          }
;

TEXT_STRING_sys_nonewline:
TEXT_STRING_sys {
            if (!strcont($1.str, "\n"))
              $$= $1;
            else
            {
              my_error(ER_WRONG_VALUE, MYF(0), "argument contains not-allowed LF", $1.str);
              MYSQL_YYABORT;
            }
          }
;

filter_wild_db_table_string:
TEXT_STRING_sys_nonewline {
            if (strcont($1.str, "."))
              $$= $1;
            else
            {
              my_error(ER_INVALID_RPL_WILD_TABLE_FILTER_PATTERN, MYF(0));
              MYSQL_YYABORT;
            }
          }
;

TEXT_STRING_sys:
TEXT_STRING {
            THD *thd= YYTHD;

            if (thd->charset_is_system_charset)
              $$= $1;
            else
            {
              if (thd->convert_string(&$$, system_charset_info,
                                  $1.str, $1.length, thd->charset()))
                MYSQL_YYABORT;
            }
          }
;

TEXT_STRING_literal:
TEXT_STRING {
            THD *thd= YYTHD;

            if (thd->charset_is_collation_connection)
              $$= $1;
            else
            {
              if (thd->convert_string(&$$, thd->variables.collation_connection,
                                  $1.str, $1.length, thd->charset()))
                MYSQL_YYABORT;
            }
          }
;

TEXT_STRING_filesystem:
TEXT_STRING {
            THD *thd= YYTHD;

            if (thd->charset_is_character_set_filesystem)
              $$= $1;
            else
            {
              if (thd->convert_string(&$$,
                                      thd->variables.character_set_filesystem,
                                      $1.str, $1.length, thd->charset()))
                MYSQL_YYABORT;
            }
          }
;

TEXT_STRING_password:
TEXT_STRING 
;

TEXT_STRING_hash:
TEXT_STRING_sys 
|HEX_NUM {
            $$= to_lex_string(Item_hex_string::make_hex_str($1.str, $1.length));
          }
;

TEXT_STRING_validated:
TEXT_STRING {
            THD *thd= YYTHD;

            if (thd->charset_is_system_charset)
              $$= $1;
            else
            {
              if (thd->convert_string(&$$, system_charset_info,
                                  $1.str, $1.length, thd->charset(), true))
                MYSQL_YYABORT;
            }
          }
;

ident:
IDENT_sys { $$=$1; }
|ident_keyword {
            THD *thd= YYTHD;
            $$.str= thd->strmake($1.str, $1.length);
            if ($$.str == nullptr)
              MYSQL_YYABORT;
            $$.length= $1.length;
          }
;

role_ident:
IDENT_sys 
|role_keyword {
            $$.str= YYTHD->strmake($1.str, $1.length);
            if ($$.str == nullptr)
              MYSQL_YYABORT;
            $$.length= $1.length;
          }
;

label_ident:
IDENT_sys { $$=to_lex_cstring($1); }
|label_keyword {
            THD *thd= YYTHD;
            $$.str= thd->strmake($1.str, $1.length);
            if ($$.str == nullptr)
              MYSQL_YYABORT;
            $$.length= $1.length;
          }
;

lvalue_ident:
IDENT_sys 
|lvalue_keyword {
            $$.str= YYTHD->strmake($1.str, $1.length);
            if ($$.str == nullptr)
              MYSQL_YYABORT;
            $$.length= $1.length;
          }
;

ident_or_text:
ident { $$=$1;}
|TEXT_STRING_sys { $$=$1;}
|LEX_HOSTNAME { $$=$1;}
;

role_ident_or_text:
role_ident 
|TEXT_STRING_sys 
|LEX_HOSTNAME 
;

user_ident_or_text:
ident_or_text {
            if (!($$= LEX_USER::alloc(YYTHD, &$1, nullptr)))
              MYSQL_YYABORT;
          }
|ident_or_text '@' ident_or_text {
            if (!($$= LEX_USER::alloc(YYTHD, &$1, &$3)))
              MYSQL_YYABORT;
          }
;

user:
user_ident_or_text {
            $$=$1;
          }
|CURRENT_USER optional_braces {
            if (!($$= LEX_USER::alloc(YYTHD)))
              MYSQL_YYABORT;
            
          }
;

role:
role_ident_or_text {
            if (!($$= LEX_USER::alloc(YYTHD, &$1, nullptr)))
              MYSQL_YYABORT;
          }
|role_ident_or_text '@' ident_or_text {
            if (!($$= LEX_USER::alloc(YYTHD, &$1, &$3)))
              MYSQL_YYABORT;
          }
;

schema:
ident {
            $$ = $1;
            if (check_and_convert_db_name(&$$, false) != Ident_name_check::OK)
              MYSQL_YYABORT;
          }
;

ident_keyword:
ident_keywords_unambiguous 
|ident_keywords_ambiguous_1_roles_and_labels 
|ident_keywords_ambiguous_2_labels 
|ident_keywords_ambiguous_3_roles 
|ident_keywords_ambiguous_4_system_variables 
;

ident_keywords_ambiguous_1_roles_and_labels:
EXECUTE_SYM 
|RESTART_SYM 
|SHUTDOWN 
;

ident_keywords_ambiguous_2_labels:
ASCII_SYM 
|BEGIN_SYM 
|BYTE_SYM 
|CACHE_SYM 
|CHARSET 
|CHECKSUM_SYM 
|CLONE_SYM 
|COMMENT_SYM 
|COMMIT_SYM 
|CONTAINS_SYM 
|DEALLOCATE_SYM 
|DO_SYM 
|END 
|FLUSH_SYM 
|FOLLOWS_SYM 
|HANDLER_SYM 
|HELP_SYM 
|IMPORT 
|INSTALL_SYM 
|LANGUAGE_SYM 
|NO_SYM 
|PRECEDES_SYM 
|PREPARE_SYM 
|REPAIR 
|RESET_SYM 
|ROLLBACK_SYM 
|SAVEPOINT_SYM 
|SIGNED_SYM 
|SLAVE 
|START_SYM 
|STOP_SYM 
|TRUNCATE_SYM 
|UNICODE_SYM 
|UNINSTALL_SYM 
|XA_SYM 
;

label_keyword:
ident_keywords_unambiguous 
|ident_keywords_ambiguous_3_roles 
|ident_keywords_ambiguous_4_system_variables 
;

ident_keywords_ambiguous_3_roles:
EVENT_SYM 
|FILE_SYM 
|NONE_SYM 
|PROCESS 
|PROXY_SYM 
|RELOAD 
|REPLICATION 
|RESOURCE_SYM 
|SUPER_SYM 
;

ident_keywords_unambiguous:
ACTION 
|ACCOUNT_SYM 
|ACTIVE_SYM 
|ADDDATE_SYM 
|ADMIN_SYM 
|AFTER_SYM 
|AGAINST 
|AGGREGATE_SYM 
|ALGORITHM_SYM 
|ALWAYS_SYM 
|ANY_SYM 
|ARRAY_SYM 
|AT_SYM 
|ATTRIBUTE_SYM 
|AUTHENTICATION_SYM 
|AUTOEXTEND_SIZE_SYM 
|AUTO_SYM 
|AUTO_INC 
|AVG_ROW_LENGTH 
|AVG_SYM 
|BACKUP_SYM 
|BERNOULLI_SYM 
|BINLOG_SYM 
|BIT_SYM %prec KEYWORD_USED_AS_IDENT 
|BLOCK_SYM 
|BOOLEAN_SYM 
|BOOL_SYM 
|BTREE_SYM 
|BUCKETS_SYM 
|BULK_SYM 
|CASCADED 
|CATALOG_NAME_SYM 
|CHAIN_SYM 
|CHALLENGE_RESPONSE_SYM 
|CHANGED 
|CHANNEL_SYM 
|CIPHER_SYM 
|CLASS_ORIGIN_SYM 
|CLIENT_SYM 
|CLOSE_SYM 
|COALESCE 
|CODE_SYM 
|COLLATION_SYM 
|COLUMNS 
|COLUMN_FORMAT_SYM 
|COLUMN_NAME_SYM 
|COMMITTED_SYM 
|COMPACT_SYM 
|COMPLETION_SYM 
|COMPONENT_SYM 
|COMPRESSED_SYM 
|COMPRESSION_SYM 
|CONCURRENT 
|CONNECTION_SYM 
|CONSISTENT_SYM 
|CONSTRAINT_CATALOG_SYM 
|CONSTRAINT_NAME_SYM 
|CONSTRAINT_SCHEMA_SYM 
|CONTEXT_SYM 
|CPU_SYM 
|CURRENT_SYM 
|CURSOR_NAME_SYM 
|DATAFILE_SYM 
|DATA_SYM 
|DATETIME_SYM 
|DATE_SYM %prec KEYWORD_USED_AS_IDENT 
|DAY_SYM 
|DEFAULT_AUTH_SYM 
|DEFINER_SYM 
|DEFINITION_SYM 
|DELAY_KEY_WRITE_SYM 
|DESCRIPTION_SYM 
|DIAGNOSTICS_SYM 
|DIRECTORY_SYM 
|DISABLE_SYM 
|DISCARD_SYM 
|DISK_SYM 
|DUMPFILE 
|DUPLICATE_SYM 
|DYNAMIC_SYM 
|ENABLE_SYM 
|ENCRYPTION_SYM 
|ENDS_SYM 
|ENFORCED_SYM 
|ENGINES_SYM 
|ENGINE_SYM 
|ENGINE_ATTRIBUTE_SYM 
|ENUM_SYM 
|ERRORS 
|ERROR_SYM 
|ESCAPE_SYM 
|EVENTS_SYM 
|EVERY_SYM 
|EXCHANGE_SYM 
|EXCLUDE_SYM 
|EXPANSION_SYM 
|EXPIRE_SYM 
|EXPORT_SYM 
|EXTENDED_SYM 
|EXTENT_SIZE_SYM 
|FACTOR_SYM 
|FAILED_LOGIN_ATTEMPTS_SYM 
|FAST_SYM 
|FAULTS_SYM 
|FILE_BLOCK_SIZE_SYM 
|FILTER_SYM 
|FINISH_SYM 
|FIRST_SYM 
|FIXED_SYM 
|FOLLOWING_SYM 
|FORMAT_SYM 
|FOUND_SYM 
|FULL {
            THD *thd= YYTHD;
            push_warning_printf(thd, Sql_condition::SL_WARNING,
                                ER_WARN_DEPRECATED_IDENT,
                                ER_THD(thd, ER_WARN_DEPRECATED_IDENT), "FULL");
          }
|GENERAL 
|GENERATE_SYM 
|GEOMETRYCOLLECTION_SYM 
|GEOMETRY_SYM 
|GET_FORMAT 
|GET_SOURCE_PUBLIC_KEY_SYM 
|GRANTS 
|GROUP_REPLICATION 
|GTIDS_SYM 
|GTID_ONLY_SYM 
|HASH_SYM 
|HISTOGRAM_SYM 
|HISTORY_SYM 
|HOSTS_SYM 
|HOST_SYM 
|HOUR_SYM 
|IDENTIFIED_SYM 
|IGNORE_SERVER_IDS_SYM 
|INACTIVE_SYM 
|INDEXES 
|INITIAL_SIZE_SYM 
|INITIAL_SYM 
|INITIATE_SYM 
|INSERT_METHOD 
|INSTANCE_SYM 
|INVISIBLE_SYM 
|INVOKER_SYM 
|IO_SYM 
|IPC_SYM 
|ISOLATION 
|ISSUER_SYM 
|JSON_SYM 
|JSON_VALUE_SYM 
|KEY_BLOCK_SIZE 
|KEYRING_SYM 
|LAST_SYM 
|LEAVES 
|LESS_SYM 
|LEVEL_SYM 
|LINESTRING_SYM 
|LIST_SYM 
|LOCKED_SYM 
|LOCKS_SYM 
|LOGFILE_SYM 
|LOGS_SYM 
|LOG_SYM 
|NETWORK_NAMESPACE_SYM 
|MASTER_SYM 
|MAX_CONNECTIONS_PER_HOUR 
|MAX_QUERIES_PER_HOUR 
|MAX_ROWS 
|MAX_SIZE_SYM 
|MAX_UPDATES_PER_HOUR 
|MAX_USER_CONNECTIONS_SYM 
|MEDIUM_SYM 
|MEMBER_SYM 
|MEMORY_SYM 
|MERGE_SYM 
|MESSAGE_TEXT_SYM 
|MICROSECOND_SYM 
|MIGRATE_SYM 
|MINUTE_SYM 
|MIN_ROWS 
|MODE_SYM 
|MODIFY_SYM 
|MONTH_SYM 
|MULTILINESTRING_SYM 
|MULTIPOINT_SYM 
|MULTIPOLYGON_SYM 
|MUTEX_SYM 
|MYSQL_ERRNO_SYM 
|NAMES_SYM %prec KEYWORD_USED_AS_IDENT 
|NAME_SYM 
|NATIONAL_SYM 
|NCHAR_SYM 
|NDBCLUSTER_SYM 
|NESTED_SYM 
|NEVER_SYM 
|NEW_SYM 
|NEXT_SYM 
|NODEGROUP_SYM 
|NOWAIT_SYM 
|NO_WAIT_SYM 
|NULLS_SYM 
|NUMBER_SYM 
|NVARCHAR_SYM 
|OFF_SYM 
|OFFSET_SYM 
|OJ_SYM 
|OLD_SYM 
|ONE_SYM 
|ONLY_SYM 
|OPEN_SYM 
|OPTIONAL_SYM 
|OPTIONS_SYM 
|ORDINALITY_SYM 
|ORGANIZATION_SYM 
|OTHERS_SYM 
|OWNER_SYM 
|PACK_KEYS_SYM 
|PAGE_SYM 
|PARSER_SYM 
|PARSE_TREE_SYM 
|PARTIAL 
|PARTITIONING_SYM 
|PARTITIONS_SYM 
|PASSWORD %prec KEYWORD_USED_AS_IDENT 
|PASSWORD_LOCK_TIME_SYM 
|PATH_SYM 
|PHASE_SYM 
|PLUGINS_SYM 
|PLUGIN_DIR_SYM 
|PLUGIN_SYM 
|POINT_SYM 
|POLYGON_SYM 
|PORT_SYM 
|PRECEDING_SYM 
|PRESERVE_SYM 
|PREV_SYM 
|PRIVILEGES 
|PRIVILEGE_CHECKS_USER_SYM 
|PROCESSLIST_SYM 
|PROFILES_SYM 
|PROFILE_SYM 
|QUARTER_SYM 
|QUERY_SYM 
|QUICK 
|RANDOM_SYM 
|READ_ONLY_SYM 
|REBUILD_SYM 
|RECOVER_SYM 
|REDO_BUFFER_SIZE_SYM 
|REDUNDANT_SYM 
|REFERENCE_SYM 
|REGISTRATION_SYM 
|RELAY 
|RELAYLOG_SYM 
|RELAY_LOG_FILE_SYM 
|RELAY_LOG_POS_SYM 
|RELAY_THREAD 
|REMOVE_SYM 
|ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS_SYM 
|REORGANIZE_SYM 
|REPEATABLE_SYM 
|REPLICAS_SYM 
|REPLICATE_DO_DB 
|REPLICATE_DO_TABLE 
|REPLICATE_IGNORE_DB 
|REPLICATE_IGNORE_TABLE 
|REPLICATE_REWRITE_DB 
|REPLICATE_WILD_DO_TABLE 
|REPLICATE_WILD_IGNORE_TABLE 
|REPLICA_SYM 
|REQUIRE_ROW_FORMAT_SYM 
|REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYM 
|RESOURCES 
|RESPECT_SYM 
|RESTORE_SYM 
|RESUME_SYM 
|RETAIN_SYM 
|RETURNED_SQLSTATE_SYM 
|RETURNING_SYM 
|RETURNS_SYM 
|REUSE_SYM 
|REVERSE_SYM 
|ROLE_SYM 
|ROLLUP_SYM 
|ROTATE_SYM 
|ROUTINE_SYM 
|ROW_COUNT_SYM 
|ROW_FORMAT_SYM 
|RTREE_SYM 
|S3_SYM 
|SCHEDULE_SYM 
|SCHEMA_NAME_SYM 
|SECONDARY_ENGINE_SYM 
|SECONDARY_ENGINE_ATTRIBUTE_SYM 
|SECONDARY_LOAD_SYM 
|SECONDARY_SYM 
|SECONDARY_UNLOAD_SYM 
|SECOND_SYM 
|SECURITY_SYM 
|SERIALIZABLE_SYM 
|SERIAL_SYM 
|SERVER_SYM 
|SHARE_SYM 
|SIMPLE_SYM 
|SKIP_SYM 
|SLOW 
|SNAPSHOT_SYM 
|SOCKET_SYM 
|SONAME_SYM 
|SOUNDS_SYM 
|SOURCE_AUTO_POSITION_SYM 
|SOURCE_BIND_SYM 
|SOURCE_COMPRESSION_ALGORITHM_SYM 
|SOURCE_CONNECTION_AUTO_FAILOVER_SYM 
|SOURCE_CONNECT_RETRY_SYM 
|SOURCE_DELAY_SYM 
|SOURCE_HEARTBEAT_PERIOD_SYM 
|SOURCE_HOST_SYM 
|SOURCE_LOG_FILE_SYM 
|SOURCE_LOG_POS_SYM 
|SOURCE_PASSWORD_SYM 
|SOURCE_PORT_SYM 
|SOURCE_PUBLIC_KEY_PATH_SYM 
|SOURCE_RETRY_COUNT_SYM 
|SOURCE_SSL_CAPATH_SYM 
|SOURCE_SSL_CA_SYM 
|SOURCE_SSL_CERT_SYM 
|SOURCE_SSL_CIPHER_SYM 
|SOURCE_SSL_CRLPATH_SYM 
|SOURCE_SSL_CRL_SYM 
|SOURCE_SSL_KEY_SYM 
|SOURCE_SSL_SYM 
|SOURCE_SSL_VERIFY_SERVER_CERT_SYM 
|SOURCE_SYM 
|SOURCE_TLS_CIPHERSUITES_SYM 
|SOURCE_TLS_VERSION_SYM 
|SOURCE_USER_SYM 
|SOURCE_ZSTD_COMPRESSION_LEVEL_SYM 
|SQL_AFTER_GTIDS 
|SQL_AFTER_MTS_GAPS 
|SQL_BEFORE_GTIDS 
|SQL_BUFFER_RESULT 
|SQL_NO_CACHE_SYM 
|SQL_THREAD 
|SRID_SYM 
|STACKED_SYM 
|STARTS_SYM 
|STATS_AUTO_RECALC_SYM 
|STATS_PERSISTENT_SYM 
|STATS_SAMPLE_PAGES_SYM 
|STATUS_SYM 
|STORAGE_SYM 
|STREAM_SYM 
|STRING_SYM 
|ST_COLLECT_SYM 
|SUBCLASS_ORIGIN_SYM 
|SUBDATE_SYM 
|SUBJECT_SYM 
|SUBPARTITIONS_SYM 
|SUBPARTITION_SYM 
|SUSPEND_SYM 
|SWAPS_SYM 
|SWITCHES_SYM 
|TABLES 
|TABLESPACE_SYM 
|TABLE_CHECKSUM_SYM 
|TABLE_NAME_SYM 
|TEMPORARY 
|TEMPTABLE_SYM 
|TEXT_SYM 
|THAN_SYM 
|THREAD_PRIORITY_SYM 
|TIES_SYM 
|TIMESTAMP_ADD 
|TIMESTAMP_DIFF 
|TIMESTAMP_SYM %prec KEYWORD_USED_AS_IDENT 
|TIME_SYM %prec KEYWORD_USED_AS_IDENT 
|TLS_SYM 
|TRANSACTION_SYM 
|TRIGGERS_SYM 
|TYPES_SYM 
|TYPE_SYM 
|UNBOUNDED_SYM 
|UNCOMMITTED_SYM 
|UNDEFINED_SYM 
|UNDOFILE_SYM 
|UNDO_BUFFER_SIZE_SYM 
|UNKNOWN_SYM 
|UNREGISTER_SYM 
|UNTIL_SYM 
|UPGRADE_SYM 
|URL_SYM 
|USER 
|USE_FRM 
|VALIDATION_SYM 
|VALUE_SYM 
|VARIABLES 
|VCPU_SYM 
|VIEW_SYM 
|VISIBLE_SYM 
|WAIT_SYM 
|WARNINGS 
|WEEK_SYM 
|WEIGHT_STRING_SYM 
|WITHOUT_SYM 
|WORK_SYM 
|WRAPPER_SYM 
|X509_SYM 
|XID_SYM 
|XML_SYM 
|YEAR_SYM 
|ZONE_SYM 
;

role_keyword:
ident_keywords_unambiguous 
|ident_keywords_ambiguous_2_labels 
|ident_keywords_ambiguous_4_system_variables 
;

lvalue_keyword:
ident_keywords_unambiguous 
|ident_keywords_ambiguous_1_roles_and_labels 
|ident_keywords_ambiguous_2_labels 
|ident_keywords_ambiguous_3_roles 
;

ident_keywords_ambiguous_4_system_variables:
GLOBAL_SYM 
|LOCAL_SYM 
|PERSIST_SYM 
|PERSIST_ONLY_SYM 
|SESSION_SYM 
;

set:
SET_SYM start_option_value_list {
            $$= NEW_PTN PT_set(@$, @1, $2);
          }
;

start_option_value_list:
option_value_no_option_type option_value_list_continued {
            $$= NEW_PTN PT_start_option_value_list_no_type(@$, $1, @1, $2);
          }
|TRANSACTION_SYM transaction_characteristics {
            $$= NEW_PTN PT_start_option_value_list_transaction(@$, $2, @2);
          }
|option_type start_option_value_list_following_option_type {
            $$= NEW_PTN PT_start_option_value_list_type(@$, $1, $2);
          }
|PASSWORD equal TEXT_STRING_password opt_replace_password opt_retain_current_password {
            $$= NEW_PTN PT_option_value_no_option_type_password(@$, $3.str, $4.str,
                                                                $5,
                                                                false,
                                                                @4);
          }
|PASSWORD TO_SYM RANDOM_SYM opt_replace_password opt_retain_current_password {
            
            $$= NEW_PTN PT_option_value_no_option_type_password(@$, $3.str, $4.str,
                                                                $5,
                                                                true,
                                                                @4);
          }
|PASSWORD FOR_SYM user equal TEXT_STRING_password opt_replace_password opt_retain_current_password {
            $$= NEW_PTN PT_option_value_no_option_type_password_for(@$, $3, $5.str,
                                                                    $6.str,
                                                                    $7,
                                                                    false,
                                                                    @6);
          }
|PASSWORD FOR_SYM user TO_SYM RANDOM_SYM opt_replace_password opt_retain_current_password {
            
            $$= NEW_PTN PT_option_value_no_option_type_password_for(@$, $3, $5.str,
                                                                    $6.str,
                                                                    $7,
                                                                    true,
                                                                    @6);
          }
;

set_role_stmt:
SET_SYM ROLE_SYM role_list {
            $$= NEW_PTN PT_set_role(@$, $3);
          }
|SET_SYM ROLE_SYM NONE_SYM {
            $$= NEW_PTN PT_set_role(@$, role_enum::ROLE_NONE);
            Lex->sql_command= SQLCOM_SET_ROLE;
          }
|SET_SYM ROLE_SYM DEFAULT_SYM {
            $$= NEW_PTN PT_set_role(@$, role_enum::ROLE_DEFAULT);
            Lex->sql_command= SQLCOM_SET_ROLE;
          }
|SET_SYM DEFAULT_SYM ROLE_SYM role_list TO_SYM role_list {
            $$= NEW_PTN PT_alter_user_default_role(@$, false, $6, $4,
                                                    role_enum::ROLE_NAME);
          }
|SET_SYM DEFAULT_SYM ROLE_SYM NONE_SYM TO_SYM role_list {
            $$= NEW_PTN PT_alter_user_default_role(@$, false, $6, nullptr,
                                                   role_enum::ROLE_NONE);
          }
|SET_SYM DEFAULT_SYM ROLE_SYM ALL TO_SYM role_list {
            $$= NEW_PTN PT_alter_user_default_role(@$, false, $6, nullptr,
                                                   role_enum::ROLE_ALL);
          }
|SET_SYM ROLE_SYM ALL opt_except_role_list {
            $$= NEW_PTN PT_set_role(@$, role_enum::ROLE_ALL, $4);
            Lex->sql_command= SQLCOM_SET_ROLE;
          }
;

opt_except_role_list:
%empty { $$= nullptr; }
|EXCEPT_SYM role_list { $$= $2; }
;

set_resource_group_stmt:
SET_SYM RESOURCE_SYM GROUP_SYM ident {
            $$= NEW_PTN PT_set_resource_group(@$, to_lex_cstring($4), nullptr);
          }
|SET_SYM RESOURCE_SYM GROUP_SYM ident FOR_SYM thread_id_list_options {
            $$= NEW_PTN PT_set_resource_group(@$, to_lex_cstring($4), $6);
          }
;

thread_id_list:
real_ulong_num {
            $$= NEW_PTN Mem_root_array<ulonglong>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|thread_id_list opt_comma real_ulong_num {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

thread_id_list_options:
thread_id_list { $$= $1; }
;

start_option_value_list_following_option_type:
option_value_following_option_type option_value_list_continued {
            $$=
              NEW_PTN PT_start_option_value_list_following_option_type_eq(@$, $1,
                                                                          @1,
                                                                          $2);
          }
|TRANSACTION_SYM transaction_characteristics {
            $$= NEW_PTN
              PT_start_option_value_list_following_option_type_transaction(@$, $2,
                                                                           @2);
          }
;

option_value_list_continued:
%empty { $$= nullptr; }
|',' option_value_list { $$= $2; }
;

option_value_list:
option_value {
            $$= NEW_PTN PT_option_value_list_head(@$, @0, $1, @1);
          }
|option_value_list ',' option_value {
            $$= NEW_PTN PT_option_value_list(@$, $1, @2, $3, @3);
          }
;

option_value:
option_type option_value_following_option_type {
            $$= NEW_PTN PT_option_value_type(@$, $1, $2);
          }
|option_value_no_option_type { $$= $1; }
;

option_type:
GLOBAL_SYM { $$=OPT_GLOBAL; }
|PERSIST_SYM { $$=OPT_PERSIST; }
|PERSIST_ONLY_SYM { $$=OPT_PERSIST_ONLY; }
|LOCAL_SYM { $$=OPT_SESSION; }
|SESSION_SYM { $$=OPT_SESSION; }
;

opt_var_type:
%empty { $$=OPT_SESSION; }
|GLOBAL_SYM { $$=OPT_GLOBAL; }
|LOCAL_SYM { $$=OPT_SESSION; }
|SESSION_SYM { $$=OPT_SESSION; }
;

opt_rvalue_system_variable_type:
%empty { $$=OPT_DEFAULT; }
|GLOBAL_SYM '.' { $$=OPT_GLOBAL; }
|LOCAL_SYM '.' { $$=OPT_SESSION; }
|SESSION_SYM '.' { $$=OPT_SESSION; }
;

opt_set_var_ident_type:
%empty { $$=OPT_DEFAULT; }
|PERSIST_SYM '.' { $$=OPT_PERSIST; }
|PERSIST_ONLY_SYM '.' {$$=OPT_PERSIST_ONLY; }
|GLOBAL_SYM '.' { $$=OPT_GLOBAL; }
|LOCAL_SYM '.' { $$=OPT_SESSION; }
|SESSION_SYM '.' { $$=OPT_SESSION; }
;

option_value_following_option_type:
lvalue_variable equal set_expr_or_default {
            $$ = NEW_PTN PT_set_scoped_system_variable(
                @$, @1, $1.prefix, $1.name, $3);
          }
;

option_value_no_option_type:
lvalue_variable equal set_expr_or_default {
            $$ = NEW_PTN PT_set_variable(@$, @1, $1.prefix, $1.name, @3, $3);
          }
|'@' ident_or_text equal expr {
            $$= NEW_PTN PT_option_value_no_option_type_user_var(@$, $2, $4);
          }
|'@' '@' opt_set_var_ident_type lvalue_variable equal set_expr_or_default {
            $$ = NEW_PTN PT_set_system_variable(
                @$, $3, @4, $4.prefix, $4.name, $6);
          }
|character_set old_or_new_charset_name_or_default {
            $$= NEW_PTN PT_option_value_no_option_type_charset(@$, $2);
          }
|NAMES_SYM equal expr {
            
            $$= NEW_PTN PT_option_value_no_option_type_names(@$, @2);
          }
|NAMES_SYM charset_name opt_collate {
            $$= NEW_PTN PT_set_names(@$, $2, $3);
          }
|NAMES_SYM DEFAULT_SYM {
            $$ = NEW_PTN PT_set_names(@$, nullptr, nullptr);
          }
;

lvalue_variable:
lvalue_ident {
            $$ = Bipartite_name{{}, to_lex_cstring($1)};
          }
|lvalue_ident '.' ident {
            
            if (check_reserved_words($1.str)) {
              YYTHD->syntax_error_at(@1);
              MYSQL_YYABORT;
            }
            $$ = Bipartite_name{to_lex_cstring($1), to_lex_cstring($3)};
          }
|DEFAULT_SYM '.' ident {
            $$ = Bipartite_name{{STRING_WITH_LEN("default")}, to_lex_cstring($3)};
          }
;

rvalue_system_variable:
ident_or_text {
            $$ = Bipartite_name{{}, to_lex_cstring($1)};
          }
|ident_or_text '.' ident {
            
            if (check_reserved_words($1.str)) {
              YYTHD->syntax_error_at(@1);
              MYSQL_YYABORT;
            }
            $$ = Bipartite_name{to_lex_cstring($1), to_lex_cstring($3)};
          }
;

transaction_characteristics:
transaction_access_mode opt_isolation_level {
            $$= NEW_PTN PT_transaction_characteristics(@$, $1, $2);
          }
|isolation_level opt_transaction_access_mode {
            $$= NEW_PTN PT_transaction_characteristics(@$, $1, $2);
          }
;

transaction_access_mode:
transaction_access_mode_types {
            $$= NEW_PTN PT_transaction_access_mode(@$, $1);
          }
;

opt_transaction_access_mode:
%empty { $$= nullptr; }
|',' transaction_access_mode { $$= $2; }
;

isolation_level:
ISOLATION LEVEL_SYM isolation_types {
            $$= NEW_PTN PT_isolation_level(@$, $3);
          }
;

opt_isolation_level:
%empty { $$= nullptr; }
|',' isolation_level { $$= $2; }
;

transaction_access_mode_types:
READ_SYM ONLY_SYM { $$= true; }
|READ_SYM WRITE_SYM { $$= false; }
;

isolation_types:
READ_SYM UNCOMMITTED_SYM { $$= ISO_READ_UNCOMMITTED; }
|READ_SYM COMMITTED_SYM { $$= ISO_READ_COMMITTED; }
|REPEATABLE_SYM READ_SYM { $$= ISO_REPEATABLE_READ; }
|SERIALIZABLE_SYM { $$= ISO_SERIALIZABLE; }
;

set_expr_or_default:
expr 
|DEFAULT_SYM { $$= nullptr; }
|ON_SYM {
            $$= NEW_PTN Item_string(@$, "ON", 2, system_charset_info);
          }
|ALL {
            $$= NEW_PTN Item_string(@$, "ALL", 3, system_charset_info);
          }
|BINARY_SYM {
            $$= NEW_PTN Item_string(@$, "binary", 6, system_charset_info);
          }
|ROW_SYM {
            $$= NEW_PTN Item_string(@$, "ROW", 3, system_charset_info);
          }
|SYSTEM_SYM {
            $$= NEW_PTN Item_string(@$, "SYSTEM", 6, system_charset_info);
          }
;

lock:
LOCK_SYM table_or_tables {
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_BADSTATEMENT, MYF(0), "LOCK");
              MYSQL_YYABORT;
            }
            lex->sql_command= SQLCOM_LOCK_TABLES;
          }table_lock_list {}
|LOCK_SYM INSTANCE_SYM FOR_SYM BACKUP_SYM {
            Lex->sql_command= SQLCOM_LOCK_INSTANCE;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_lock_instance();
            if (Lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT; 
          }
;

table_or_tables:
TABLE_SYM 
|TABLES 
;

table_lock_list:
table_lock 
|table_lock_list ',' table_lock 
;

table_lock:
table_ident opt_table_alias lock_option {
            thr_lock_type lock_type= (thr_lock_type) $3;
            enum_mdl_type mdl_lock_type;

            if (lock_type >= TL_WRITE_ALLOW_WRITE)
            {
              
              mdl_lock_type= MDL_SHARED_NO_READ_WRITE;
            }
            else if (lock_type == TL_READ)
            {
              
              mdl_lock_type= MDL_SHARED_READ;
            }
            else
            {
              
              mdl_lock_type= MDL_SHARED_READ_ONLY;
            }

            if (!Select->add_table_to_list(YYTHD, $1, $2.str, 0, lock_type,
                                           mdl_lock_type))
              MYSQL_YYABORT;
          }
;

lock_option:
READ_SYM { $$= TL_READ_NO_INSERT; }
|WRITE_SYM { $$= TL_WRITE_DEFAULT; }
|READ_SYM LOCAL_SYM { $$= TL_READ; }
;

unlock:
UNLOCK_SYM {
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_BADSTATEMENT, MYF(0), "UNLOCK");
              MYSQL_YYABORT;
            }
            lex->sql_command= SQLCOM_UNLOCK_TABLES;
          }table_or_tables {}
|UNLOCK_SYM INSTANCE_SYM {
            Lex->sql_command= SQLCOM_UNLOCK_INSTANCE;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_unlock_instance();
            if (Lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT; 
          }
;

shutdown_stmt:
SHUTDOWN {
            Lex->sql_command= SQLCOM_SHUTDOWN;
            $$= NEW_PTN PT_shutdown();
          }
;

restart_server_stmt:
RESTART_SYM {
            $$= NEW_PTN PT_restart_server();
          }
;

alter_instance_stmt:
ALTER INSTANCE_SYM alter_instance_action {
            Lex->sql_command= SQLCOM_ALTER_INSTANCE;
            $$= $3;
          }

alter_instance_action:
ROTATE_SYM ident_or_text MASTER_SYM KEY_SYM {
            if (is_identifier($2, "INNODB"))
            {
              $$= NEW_PTN PT_alter_instance(@$, ROTATE_INNODB_MASTER_KEY, EMPTY_CSTR);
            }
            else if (is_identifier($2, "BINLOG"))
            {
              $$= NEW_PTN PT_alter_instance(@$, ROTATE_BINLOG_MASTER_KEY, EMPTY_CSTR);
            }
            else
            {
              YYTHD->syntax_error_at(@2);
              MYSQL_YYABORT;
            }
          }
|RELOAD TLS_SYM {
            $$ = NEW_PTN PT_alter_instance(@$, ALTER_INSTANCE_RELOAD_TLS_ROLLBACK_ON_ERROR, to_lex_cstring("mysql_main"));
          }
|RELOAD TLS_SYM NO_SYM ROLLBACK_SYM ON_SYM ERROR_SYM {
            $$ = NEW_PTN PT_alter_instance(@$, ALTER_INSTANCE_RELOAD_TLS, to_lex_cstring("mysql_main"));
          }
|RELOAD TLS_SYM FOR_SYM CHANNEL_SYM ident {
            $$ = NEW_PTN PT_alter_instance(@$, ALTER_INSTANCE_RELOAD_TLS_ROLLBACK_ON_ERROR, to_lex_cstring($5));
          }
|RELOAD TLS_SYM FOR_SYM CHANNEL_SYM ident NO_SYM ROLLBACK_SYM ON_SYM ERROR_SYM {
            $$ = NEW_PTN PT_alter_instance(@$, ALTER_INSTANCE_RELOAD_TLS, to_lex_cstring($5));
          }
|ENABLE_SYM ident ident {
            if (!is_identifier($2, "INNODB"))
            {
              YYTHD->syntax_error_at(@2);
              MYSQL_YYABORT;
            }

            if (!is_identifier($3, "REDO_LOG"))
            {
              YYTHD->syntax_error_at(@3);
              MYSQL_YYABORT;
            }
            $$ = NEW_PTN PT_alter_instance(@$, ALTER_INSTANCE_ENABLE_INNODB_REDO, EMPTY_CSTR);
          }
|DISABLE_SYM ident ident {
            if (!is_identifier($2, "INNODB"))
            {
              YYTHD->syntax_error_at(@2);
              MYSQL_YYABORT;
            }

            if (!is_identifier($3, "REDO_LOG"))
            {
              YYTHD->syntax_error_at(@3);
              MYSQL_YYABORT;
            }
            $$ = NEW_PTN PT_alter_instance(@$, ALTER_INSTANCE_DISABLE_INNODB_REDO, EMPTY_CSTR);
          }
|RELOAD KEYRING_SYM {
            $$ = NEW_PTN PT_alter_instance(@$, RELOAD_KEYRING, EMPTY_CSTR);
          }
;

handler_stmt:
HANDLER_SYM table_ident OPEN_SYM opt_table_alias {
            $$= NEW_PTN PT_handler_open($2, $4);
          }
|HANDLER_SYM ident CLOSE_SYM {
            $$= NEW_PTN PT_handler_close(to_lex_cstring($2));
          }
|HANDLER_SYM ident READ_SYM handler_scan_function opt_where_clause opt_limit_clause {
            $$= NEW_PTN PT_handler_table_scan(to_lex_cstring($2), $4, $5, $6);
          }
|HANDLER_SYM ident READ_SYM ident handler_rkey_function opt_where_clause opt_limit_clause {
            $$= NEW_PTN PT_handler_index_scan(to_lex_cstring($2),
                                              to_lex_cstring($4), $5, $6, $7);
          }
|HANDLER_SYM ident READ_SYM ident handler_rkey_mode '(' values ')' opt_where_clause opt_limit_clause {
            $$= NEW_PTN PT_handler_index_range_scan(to_lex_cstring($2),
                                                    to_lex_cstring($4),
                                                    $5, $7, $9, $10);
          }
;

handler_scan_function:
FIRST_SYM { $$= enum_ha_read_modes::RFIRST; }
|NEXT_SYM { $$= enum_ha_read_modes::RNEXT;  }
;

handler_rkey_function:
FIRST_SYM { $$= enum_ha_read_modes::RFIRST; }
|NEXT_SYM { $$= enum_ha_read_modes::RNEXT;  }
|PREV_SYM { $$= enum_ha_read_modes::RPREV;  }
|LAST_SYM { $$= enum_ha_read_modes::RLAST;  }
;

handler_rkey_mode:
EQ { $$=HA_READ_KEY_EXACT;   }
|GE { $$=HA_READ_KEY_OR_NEXT; }
|LE { $$=HA_READ_KEY_OR_PREV; }
|GT_SYM { $$=HA_READ_AFTER_KEY;   }
|LT { $$=HA_READ_BEFORE_KEY;  }
;

revoke:
REVOKE if_exists role_or_privilege_list FROM user_list opt_ignore_unknown_user {
            Lex->grant_if_exists = $2;
            Lex->ignore_unknown_user = $6;
            auto *tmp= NEW_PTN PT_revoke_roles(@$, $3, $5);
            MAKE_CMD(tmp);
          }
|REVOKE if_exists role_or_privilege_list ON_SYM opt_acl_type grant_ident FROM user_list opt_ignore_unknown_user {
            LEX *lex= Lex;
            lex->grant_if_exists = $2;
            Lex->ignore_unknown_user = $9;
            if (apply_privileges(YYTHD, *$3))
              MYSQL_YYABORT;
            lex->sql_command= (lex->grant == GLOBAL_ACLS) ? SQLCOM_REVOKE_ALL
                                                          : SQLCOM_REVOKE;
            if ($5 != Acl_type::TABLE && !lex->columns.is_empty())
            {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
            lex->type= static_cast<ulong>($5);
            lex->users_list= *$8;
            MAKE_CMD_DCL_DUMMY();
          }
|REVOKE if_exists ALL opt_privileges {
            Lex->grant_if_exists = $2;
            Lex->all_privileges= 1;
            Lex->grant= GLOBAL_ACLS;
          }ON_SYM opt_acl_type grant_ident FROM user_list opt_ignore_unknown_user {
            LEX *lex= Lex;
            lex->sql_command= (lex->grant == (GLOBAL_ACLS & ~GRANT_ACL)) ?
                                                            SQLCOM_REVOKE_ALL
                                                          : SQLCOM_REVOKE;
            if ($7 != Acl_type::TABLE && !lex->columns.is_empty())
            {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
            lex->type= static_cast<ulong>($7);
            lex->users_list= *$10;
            lex->ignore_unknown_user = $11;
            MAKE_CMD_DCL_DUMMY();
          }
|REVOKE if_exists ALL opt_privileges ',' GRANT OPTION FROM user_list opt_ignore_unknown_user {
            Lex->grant_if_exists = $2;
            Lex->ignore_unknown_user = $10;
            Lex->sql_command = SQLCOM_REVOKE_ALL;
            Lex->users_list= *$9;
            MAKE_CMD_DCL_DUMMY();
          }
|REVOKE if_exists PROXY_SYM ON_SYM user FROM user_list opt_ignore_unknown_user {
            LEX *lex= Lex;
            lex->grant_if_exists = $2;
            lex->ignore_unknown_user = $8;
            lex->sql_command= SQLCOM_REVOKE;
            lex->users_list= *$7;
            lex->users_list.push_front ($5);
            lex->type= TYPE_ENUM_PROXY;
            MAKE_CMD_DCL_DUMMY();
          }
;

grant:
GRANT role_or_privilege_list TO_SYM user_list opt_with_admin_option {
            auto *tmp= NEW_PTN PT_grant_roles(@$, $2, $4, $5);
            MAKE_CMD(tmp);
          }
|GRANT role_or_privilege_list ON_SYM opt_acl_type grant_ident TO_SYM user_list grant_options opt_grant_as {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_GRANT;
            if (apply_privileges(YYTHD, *$2))
              MYSQL_YYABORT;

            if ($4 != Acl_type::TABLE && !lex->columns.is_empty())
            {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
            lex->type= static_cast<ulong>($4);
            lex->users_list= *$7;
            MAKE_CMD_DCL_DUMMY();
          }
|GRANT ALL opt_privileges {
            Lex->all_privileges= 1;
            Lex->grant= GLOBAL_ACLS;
          }ON_SYM opt_acl_type grant_ident TO_SYM user_list grant_options opt_grant_as {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_GRANT;
            if ($6 != Acl_type::TABLE && !lex->columns.is_empty())
            {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }
            lex->type= static_cast<ulong>($6);
            lex->users_list= *$9;
            MAKE_CMD_DCL_DUMMY();
          }
|GRANT PROXY_SYM ON_SYM user TO_SYM user_list opt_grant_option {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_GRANT;
            if ($7)
              lex->grant |= GRANT_ACL;
            lex->users_list= *$6;
            lex->users_list.push_front ($4);
            lex->type= TYPE_ENUM_PROXY;
            MAKE_CMD_DCL_DUMMY();
          }
;

opt_acl_type:
%empty { $$= Acl_type::TABLE; }
|TABLE_SYM { $$= Acl_type::TABLE; }
|FUNCTION_SYM { $$= Acl_type::FUNCTION; }
|PROCEDURE_SYM { $$= Acl_type::PROCEDURE; }
;

opt_privileges:
%empty 
|PRIVILEGES 
;

role_or_privilege_list:
role_or_privilege {
            $$= NEW_PTN Mem_root_array<PT_role_or_privilege *>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT; 
          }
|role_or_privilege_list ',' role_or_privilege {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

role_or_privilege:
role_ident_or_text opt_column_list {
            if ($2 == nullptr)
              $$= NEW_PTN PT_role_or_dynamic_privilege(@$, @1, $1);
            else
              $$= NEW_PTN PT_dynamic_privilege(@$, @1, $1);
          }
|role_ident_or_text '@' ident_or_text { $$= NEW_PTN PT_role_at_host(@$, @1, $1, $3); }
|SELECT_SYM opt_column_list { $$= NEW_PTN PT_static_privilege(@$, @1, SELECT_ACL, $2); }
|INSERT_SYM opt_column_list { $$= NEW_PTN PT_static_privilege(@$, @1, INSERT_ACL, $2); }
|UPDATE_SYM opt_column_list { $$= NEW_PTN PT_static_privilege(@$, @1, UPDATE_ACL, $2); }
|REFERENCES opt_column_list { $$= NEW_PTN PT_static_privilege(@$, @1, REFERENCES_ACL, $2); }
|DELETE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, DELETE_ACL); }
|USAGE { $$= NEW_PTN PT_static_privilege(@$, @1, 0); }
|INDEX_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, INDEX_ACL); }
|ALTER { $$= NEW_PTN PT_static_privilege(@$, @1, ALTER_ACL); }
|CREATE { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_ACL); }
|DROP { $$= NEW_PTN PT_static_privilege(@$, @1, DROP_ACL); }
|EXECUTE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, EXECUTE_ACL); }
|RELOAD { $$= NEW_PTN PT_static_privilege(@$, @1, RELOAD_ACL); }
|SHUTDOWN { $$= NEW_PTN PT_static_privilege(@$, @1, SHUTDOWN_ACL); }
|PROCESS { $$= NEW_PTN PT_static_privilege(@$, @1, PROCESS_ACL); }
|FILE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, FILE_ACL); }
|GRANT OPTION {
            $$= NEW_PTN PT_static_privilege(@$, @1, GRANT_ACL);
            Lex->grant_privilege= true;
          }
|SHOW DATABASES { $$= NEW_PTN PT_static_privilege(@$, @1, SHOW_DB_ACL); }
|SUPER_SYM {
            
            $$= NEW_PTN PT_static_privilege(@$, @1, SUPER_ACL);
            if (Lex->grant != GLOBAL_ACLS)
            {
              
              push_warning(Lex->thd, Sql_condition::SL_WARNING,
                           ER_WARN_DEPRECATED_SYNTAX,
                           "The SUPER privilege identifier is deprecated");
            }
          }
|CREATE TEMPORARY TABLES { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_TMP_ACL); }
|LOCK_SYM TABLES { $$= NEW_PTN PT_static_privilege(@$, @1, LOCK_TABLES_ACL); }
|REPLICATION SLAVE { $$= NEW_PTN PT_static_privilege(@$, @1, REPL_SLAVE_ACL); }
|REPLICATION CLIENT_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, REPL_CLIENT_ACL); }
|CREATE VIEW_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_VIEW_ACL); }
|SHOW VIEW_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, SHOW_VIEW_ACL); }
|CREATE ROUTINE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_PROC_ACL); }
|ALTER ROUTINE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, ALTER_PROC_ACL); }
|CREATE USER { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_USER_ACL); }
|EVENT_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, EVENT_ACL); }
|TRIGGER_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, TRIGGER_ACL); }
|CREATE TABLESPACE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_TABLESPACE_ACL); }
|CREATE ROLE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, CREATE_ROLE_ACL); }
|DROP ROLE_SYM { $$= NEW_PTN PT_static_privilege(@$, @1, DROP_ROLE_ACL); }
;

opt_with_admin_option:
%empty { $$= false; }
|WITH ADMIN_SYM OPTION { $$= true; }
;

opt_and:
%empty 
|AND_SYM 
;

require_list:
require_list_element opt_and require_list 
|require_list_element 
;

require_list_element:
SUBJECT_SYM TEXT_STRING {
            LEX *lex=Lex;
            if (lex->x509_subject)
            {
              my_error(ER_DUP_ARGUMENT, MYF(0), "SUBJECT");
              MYSQL_YYABORT;
            }
            lex->x509_subject=$2.str;
          }
|ISSUER_SYM TEXT_STRING {
            LEX *lex=Lex;
            if (lex->x509_issuer)
            {
              my_error(ER_DUP_ARGUMENT, MYF(0), "ISSUER");
              MYSQL_YYABORT;
            }
            lex->x509_issuer=$2.str;
          }
|CIPHER_SYM TEXT_STRING {
            LEX *lex=Lex;
            if (lex->ssl_cipher)
            {
              my_error(ER_DUP_ARGUMENT, MYF(0), "CIPHER");
              MYSQL_YYABORT;
            }
            lex->ssl_cipher=$2.str;
          }
;

grant_ident:
'*' {
            LEX *lex= Lex;
            size_t dummy;
            if (lex->copy_db_to(&lex->current_query_block()->db, &dummy))
              MYSQL_YYABORT;
            if (lex->grant == GLOBAL_ACLS)
              lex->grant = DB_OP_ACLS;
            else if (lex->columns.elements)
            {
              my_error(ER_ILLEGAL_GRANT_FOR_TABLE, MYF(0));
              MYSQL_YYABORT;
            }
          }
|schema '.' '*' {
            LEX *lex= Lex;
            lex->current_query_block()->db = $1.str;
            if (lex->grant == GLOBAL_ACLS)
              lex->grant = DB_OP_ACLS;
            else if (lex->columns.elements)
            {
              my_error(ER_ILLEGAL_GRANT_FOR_TABLE, MYF(0));
              MYSQL_YYABORT;
            }
          }
|'*' '.' '*' {
            LEX *lex= Lex;
            lex->current_query_block()->db = nullptr;
            if (lex->grant == GLOBAL_ACLS)
              lex->grant= GLOBAL_ACLS & ~GRANT_ACL;
            else if (lex->columns.elements)
            {
              my_error(ER_ILLEGAL_GRANT_FOR_TABLE, MYF(0));
              MYSQL_YYABORT;
            }
          }
|ident {
            auto tmp = NEW_PTN Table_ident(to_lex_cstring($1));
            if (tmp == nullptr)
              MYSQL_YYABORT;
            LEX *lex=Lex;
            if (!lex->current_query_block()->add_table_to_list(lex->thd, tmp, nullptr,
                                                        TL_OPTION_UPDATING))
              MYSQL_YYABORT;
            if (lex->grant == GLOBAL_ACLS)
              lex->grant =  TABLE_OP_ACLS;
          }
|schema '.' ident {
            auto schema_name = YYCLIENT_NO_SCHEMA ? LEX_CSTRING{}
                                                  : to_lex_cstring($1.str);
            auto tmp = NEW_PTN Table_ident(schema_name, to_lex_cstring($3));
            if (tmp == nullptr)
              MYSQL_YYABORT;
            LEX *lex=Lex;
            if (!lex->current_query_block()->add_table_to_list(lex->thd, tmp, nullptr,
                                                        TL_OPTION_UPDATING))
              MYSQL_YYABORT;
            if (lex->grant == GLOBAL_ACLS)
              lex->grant =  TABLE_OP_ACLS;
          }
;

user_list:
user {
            $$= new (YYMEM_ROOT) List<LEX_USER>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|user_list ',' user {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;
          }
;

role_list:
role {
            $$= new (YYMEM_ROOT) List<LEX_USER>;
            if ($$ == nullptr || $$->push_back($1))
              MYSQL_YYABORT;
          }
|role_list ',' role {
            $$= $1;
            if ($$->push_back($3))
              MYSQL_YYABORT;
          }
;

opt_retain_current_password:
%empty { $$= false; }
|RETAIN_SYM CURRENT_SYM PASSWORD { $$= true; }
;

opt_discard_old_password:
%empty { $$= false; }
|DISCARD_SYM OLD_SYM PASSWORD { $$= true; }

opt_user_registration:
factor INITIATE_SYM REGISTRATION_SYM {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->nth_factor= $1;
            m->init_registration= true;
            m->requires_registration= true;
            $$ = m;
          }
|factor UNREGISTER_SYM {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->nth_factor= $1;
            m->unregister= true;
            $$ = m;
          }
|factor FINISH_SYM REGISTRATION_SYM SET_SYM CHALLENGE_RESPONSE_SYM AS TEXT_STRING_hash {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->nth_factor= $1;
            m->finish_registration= true;
            m->requires_registration= true;
            m->challenge_response= to_lex_cstring($7);
            $$ = m;
          }
;

create_user:
user identification opt_create_user_with_mfa {
            $$ = $1;
            $$->first_factor_auth_info = *$2;
            if ($$->add_mfa_identifications($3.mfa2, $3.mfa3))
              MYSQL_YYABORT;  
          }
|user identified_with_plugin opt_initial_auth {
            $$= $1;
            
            $3->nth_factor = 1;
            $3->passwordless = false;
            $$->first_factor_auth_info = *$3;
            
            $2->nth_factor = 2;
            $2->passwordless = true;
            if ($$->mfa_list.push_back($2))
              MYSQL_YYABORT;  
            $$->with_initial_auth = true;
          }
|user opt_create_user_with_mfa {
            $$ = $1;
            if ($$->add_mfa_identifications($2.mfa2, $2.mfa3))
              MYSQL_YYABORT;  
          }
;

opt_create_user_with_mfa:
%empty { $$ = {}; }
|AND_SYM identification {
            $2->nth_factor = 2;
            $$ = {$2, nullptr};
          }
|AND_SYM identification AND_SYM identification {
            $2->nth_factor = 2;
            $4->nth_factor = 3;
            $$ = {$2, $4};
          }
;

identification:
identified_by_password 
|identified_by_random_password 
|identified_with_plugin 
|identified_with_plugin_as_auth 
|identified_with_plugin_by_password 
|identified_with_plugin_by_random_password 
;

identified_by_password:
IDENTIFIED_SYM BY TEXT_STRING_password {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->auth = to_lex_cstring($3);
            m->uses_identified_by_clause = true;
            $$ = m;
            Lex->contains_plaintext_password= true;
          }
;

identified_by_random_password:
IDENTIFIED_SYM BY RANDOM_SYM PASSWORD {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->auth = EMPTY_CSTR;
            m->has_password_generator = true;
            m->uses_identified_by_clause = true;
            $$ = m;
            Lex->contains_plaintext_password = true;
          }
;

identified_with_plugin:
IDENTIFIED_SYM WITH ident_or_text {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->plugin = to_lex_cstring($3);
            m->auth = EMPTY_CSTR;
            m->uses_identified_by_clause = false;
            m->uses_identified_with_clause = true;
            $$ = m;
          }
;

identified_with_plugin_as_auth:
IDENTIFIED_SYM WITH ident_or_text AS TEXT_STRING_hash {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->plugin = to_lex_cstring($3);
            m->auth = to_lex_cstring($5);
            m->uses_authentication_string_clause = true;
            m->uses_identified_with_clause = true;
            $$ = m;
          }
;

identified_with_plugin_by_password:
IDENTIFIED_SYM WITH ident_or_text BY TEXT_STRING_password {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->plugin = to_lex_cstring($3);
            m->auth = to_lex_cstring($5);
            m->uses_identified_by_clause = true;
            m->uses_identified_with_clause = true;
            $$ = m;
            Lex->contains_plaintext_password= true;
          }
;

identified_with_plugin_by_random_password:
IDENTIFIED_SYM WITH ident_or_text BY RANDOM_SYM PASSWORD {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->plugin = to_lex_cstring($3);
            m->uses_identified_by_clause = true;
            m->uses_identified_with_clause = true;
            m->has_password_generator = true;
            $$ = m;
            Lex->contains_plaintext_password= true;
          }
;

opt_initial_auth:
INITIAL_SYM AUTHENTICATION_SYM identified_by_random_password {
            $$ = $3;
            $3->passwordless = true;
            $3->nth_factor = 2;
          }
|INITIAL_SYM AUTHENTICATION_SYM identified_with_plugin_as_auth {
            $$ = $3;
            $3->passwordless = true;
            $3->nth_factor = 2;
          }
|INITIAL_SYM AUTHENTICATION_SYM identified_by_password {
            $$ = $3;
            $3->passwordless = true;
            $3->nth_factor = 2;
          }
;

alter_user:
user identified_by_password REPLACE_SYM TEXT_STRING_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->current_auth = to_lex_cstring($4);
            $1->uses_replace_clause = true;
            $1->discard_old_password = false;
            $1->retain_current_password = $5;
          }
|user identified_with_plugin_by_password REPLACE_SYM TEXT_STRING_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->current_auth = to_lex_cstring($4);
            $1->uses_replace_clause = true;
            $1->discard_old_password = false;
            $1->retain_current_password = $5;
          }
|user identified_by_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->discard_old_password = false;
            $1->retain_current_password = $3;
          }
|user identified_by_random_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->discard_old_password = false;
            $1->retain_current_password = $3;
          }
|user identified_by_random_password REPLACE_SYM TEXT_STRING_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->uses_replace_clause = true;
            $1->discard_old_password = false;
            $1->retain_current_password = $5;
            $1->current_auth = to_lex_cstring($4);
          }
|user identified_with_plugin {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->discard_old_password = false;
            $1->retain_current_password = false;
          }
|user identified_with_plugin_as_auth opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->discard_old_password = false;
            $1->retain_current_password = $3;
          }
|user identified_with_plugin_by_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->discard_old_password = false;
            $1->retain_current_password = $3;
          }
|user identified_with_plugin_by_random_password opt_retain_current_password {
            $$ = $1;
            $1->first_factor_auth_info = *$2;
            $1->discard_old_password= false;
            $1->retain_current_password= $3;
          }
|user opt_discard_old_password {
            $$ = $1;
            $1->discard_old_password = $2;
            $1->retain_current_password = false;
          }
|user ADD factor identification {
            $4->nth_factor = $3;
            $4->add_factor = true;
            if ($1->add_mfa_identifications($4))
              MYSQL_YYABORT;  
            $$ = $1;
           }
|user ADD factor identification ADD factor identification {
            if ($3 == $6) {
              my_error(ER_MFA_METHODS_IDENTICAL, MYF(0));
              MYSQL_YYABORT;
            } else if ($3 > $6) {
              my_error(ER_MFA_METHODS_INVALID_ORDER, MYF(0), $6, $3);
              MYSQL_YYABORT;
            }
            $4->nth_factor = $3;
            $4->add_factor = true;
            $7->nth_factor = $6;
            $7->add_factor = true;
            if ($1->add_mfa_identifications($4, $7))
              MYSQL_YYABORT;  
            $$ = $1;
          }
|user MODIFY_SYM factor identification {
            $4->nth_factor = $3;
            $4->modify_factor = true;
            if ($1->add_mfa_identifications($4))
              MYSQL_YYABORT;  
            $$ = $1;
           }
|user MODIFY_SYM factor identification MODIFY_SYM factor identification {
            if ($3 == $6) {
              my_error(ER_MFA_METHODS_IDENTICAL, MYF(0));
              MYSQL_YYABORT;
            }
            $4->nth_factor = $3;
            $4->modify_factor = true;
            $7->nth_factor = $6;
            $7->modify_factor = true;
            if ($1->add_mfa_identifications($4, $7))
              MYSQL_YYABORT;  
            $$ = $1;
          }
|user DROP factor {
            LEX_MFA *m = NEW_PTN LEX_MFA;
            if (m == nullptr)
              MYSQL_YYABORT;  
            m->nth_factor = $3;
            m->drop_factor = true;
            if ($1->add_mfa_identifications(m))
              MYSQL_YYABORT;  
            $$ = $1;
           }
|user DROP factor DROP factor {
            if ($3 == $5) {
              my_error(ER_MFA_METHODS_IDENTICAL, MYF(0));
              MYSQL_YYABORT;
            }
            LEX_MFA *m1 = NEW_PTN LEX_MFA;
            if (m1 == nullptr)
              MYSQL_YYABORT;  
            m1->nth_factor = $3;
            m1->drop_factor = true;
            LEX_MFA *m2 = NEW_PTN LEX_MFA;
            if (m2 == nullptr)
              MYSQL_YYABORT;  
            m2->nth_factor = $5;
            m2->drop_factor = true;
            if ($1->add_mfa_identifications(m1, m2))
              MYSQL_YYABORT;  
            $$ = $1;
           }
;

factor:
NUM FACTOR_SYM {
            if (my_strcasecmp(system_charset_info, $1.str, "2") == 0) {
              $$ = 2;
            } else if (my_strcasecmp(system_charset_info, $1.str, "3") == 0) {
              $$ = 3;
            } else {
               my_error(ER_WRONG_VALUE, MYF(0), "nth factor", $1.str);
               MYSQL_YYABORT;
            }
          }
;

create_user_list:
create_user {
            if (Lex->users_list.push_back($1))
              MYSQL_YYABORT;
          }
|create_user_list ',' create_user {
            if (Lex->users_list.push_back($3))
              MYSQL_YYABORT;
          }
;

alter_user_list:
alter_user {
            if (Lex->users_list.push_back($1))
              MYSQL_YYABORT;
         }
|alter_user_list ',' alter_user {
            if (Lex->users_list.push_back($3))
              MYSQL_YYABORT;
          }
;

opt_column_list:
%empty { $$= nullptr; }
|'(' column_list ')' { $$= $2; }
;

column_list:
ident {
            $$= NEW_PTN Mem_root_array<LEX_CSTRING>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back(to_lex_cstring($1)))
              MYSQL_YYABORT; 
          }
|column_list ',' ident {
            $$= $1;
            if ($$->push_back(to_lex_cstring($3)))
              MYSQL_YYABORT; 
          }
;

require_clause:
%empty 
|REQUIRE_SYM require_list {
            Lex->ssl_type=SSL_TYPE_SPECIFIED;
          }
|REQUIRE_SYM SSL_SYM {
            Lex->ssl_type=SSL_TYPE_ANY;
          }
|REQUIRE_SYM X509_SYM {
            Lex->ssl_type=SSL_TYPE_X509;
          }
|REQUIRE_SYM NONE_SYM {
            Lex->ssl_type=SSL_TYPE_NONE;
          }
;

grant_options:
%empty {}
|WITH GRANT OPTION { Lex->grant |= GRANT_ACL;}
;

opt_grant_option:
%empty { $$= false; }
|WITH GRANT OPTION { $$= true; }
;

opt_with_roles:
%empty { Lex->grant_as.role_type = role_enum::ROLE_NONE; }
|WITH ROLE_SYM role_list { Lex->grant_as.role_type = role_enum::ROLE_NAME;
            Lex->grant_as.role_list = $3;
          }
|WITH ROLE_SYM ALL opt_except_role_list {
            Lex->grant_as.role_type = role_enum::ROLE_ALL;
            Lex->grant_as.role_list = $4;
          }
|WITH ROLE_SYM NONE_SYM { Lex->grant_as.role_type = role_enum::ROLE_NONE; }
|WITH ROLE_SYM DEFAULT_SYM { Lex->grant_as.role_type = role_enum::ROLE_DEFAULT; }

opt_grant_as:
%empty { Lex->grant_as.grant_as_used = false; }
|AS user opt_with_roles {
            Lex->grant_as.grant_as_used = true;
            Lex->grant_as.user = $2;
          }

begin_stmt:
BEGIN_SYM {
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_BEGIN;
            lex->start_transaction_opt= 0;
          }opt_work {}
;

opt_work:
%empty {}
|WORK_SYM {}
;

opt_chain:
%empty { $$= TVL_UNKNOWN; }
|AND_SYM NO_SYM CHAIN_SYM { $$= TVL_NO; }
|AND_SYM CHAIN_SYM { $$= TVL_YES; }
;

opt_release:
%empty { $$= TVL_UNKNOWN; }
|RELEASE_SYM { $$= TVL_YES; }
|NO_SYM RELEASE_SYM { $$= TVL_NO; }
;

opt_savepoint:
%empty {}
|SAVEPOINT_SYM {}
;

commit:
COMMIT_SYM opt_work opt_chain opt_release {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_COMMIT;
            
            MYSQL_YYABORT_UNLESS($3 != TVL_YES || $4 != TVL_YES);
            lex->tx_chain= $3;
            lex->tx_release= $4;
          }
;

rollback:
ROLLBACK_SYM opt_work opt_chain opt_release {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_ROLLBACK;
            
            MYSQL_YYABORT_UNLESS($3 != TVL_YES || $4 != TVL_YES);
            lex->tx_chain= $3;
            lex->tx_release= $4;
          }
|ROLLBACK_SYM opt_work TO_SYM opt_savepoint ident {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_ROLLBACK_TO_SAVEPOINT;
            lex->ident= $5;
          }
;

savepoint:
SAVEPOINT_SYM ident {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_SAVEPOINT;
            lex->ident= $2;
          }
;

release:
RELEASE_SYM SAVEPOINT_SYM ident {
            LEX *lex=Lex;
            lex->sql_command= SQLCOM_RELEASE_SAVEPOINT;
            lex->ident= $3;
          }
;

union_option:
%empty { $$=1; }
|DISTINCT { $$=1; }
|ALL { $$=0; }
;

row_subquery:
subquery 
;

table_subquery:
subquery 
;

subquery:
query_expression_parens %prec PREFER_PARENTHESES {
            $$= NEW_PTN PT_subquery(@$, $1);
          }
;

query_spec_option:
STRAIGHT_JOIN { $$= SELECT_STRAIGHT_JOIN; }
|HIGH_PRIORITY { $$= SELECT_HIGH_PRIORITY; }
|DISTINCT { $$= SELECT_DISTINCT; }
|SQL_SMALL_RESULT { $$= SELECT_SMALL_RESULT; }
|SQL_BIG_RESULT { $$= SELECT_BIG_RESULT; }
|SQL_BUFFER_RESULT { $$= OPTION_BUFFER_RESULT; }
|SQL_CALC_FOUND_ROWS {
            push_warning(YYTHD, Sql_condition::SL_WARNING,
                         ER_WARN_DEPRECATED_SYNTAX,
                         ER_THD(YYTHD, ER_WARN_DEPRECATED_SQL_CALC_FOUND_ROWS));
            $$= OPTION_FOUND_ROWS;
          }
|ALL { $$= SELECT_ALL; }
;

init_lex_create_info:
%empty {
            
            Lex->create_info= YYTHD->alloc_typed<HA_CREATE_INFO>();
            if (Lex->create_info == nullptr)
              MYSQL_YYABORT; 
          }
;

view_or_trigger_or_sp_or_event:
definer init_lex_create_info definer_tail {}
|no_definer init_lex_create_info no_definer_tail {}
|view_replace_or_algorithm definer_opt init_lex_create_info view_tail {}
;

definer_tail:
view_tail 
|trigger_tail 
|sp_tail 
|sf_tail 
|event_tail 
;

no_definer_tail:
view_tail 
|trigger_tail 
|sp_tail 
|sf_tail 
|udf_tail 
|event_tail 
;

definer_opt:
no_definer 
|definer 
;

no_definer:
%empty {
            
            YYTHD->lex->definer= nullptr;
          }
;

definer:
DEFINER_SYM EQ user {
            YYTHD->lex->definer= get_current_user(YYTHD, $3);
          }
;

view_replace_or_algorithm:
view_replace {}
|view_replace view_algorithm {}
|view_algorithm {}
;

view_replace:
OR_SYM REPLACE_SYM { Lex->create_view_mode= enum_view_create_mode::VIEW_CREATE_OR_REPLACE; }
;

view_algorithm:
ALGORITHM_SYM EQ UNDEFINED_SYM { Lex->create_view_algorithm= VIEW_ALGORITHM_UNDEFINED; }
|ALGORITHM_SYM EQ MERGE_SYM { Lex->create_view_algorithm= VIEW_ALGORITHM_MERGE; }
|ALGORITHM_SYM EQ TEMPTABLE_SYM { Lex->create_view_algorithm= VIEW_ALGORITHM_TEMPTABLE; }
;

view_suid:
%empty { Lex->create_view_suid= VIEW_SUID_DEFAULT; }
|SQL_SYM SECURITY_SYM DEFINER_SYM { Lex->create_view_suid= VIEW_SUID_DEFINER; }
|SQL_SYM SECURITY_SYM INVOKER_SYM { Lex->create_view_suid= VIEW_SUID_INVOKER; }
;

view_tail:
view_suid VIEW_SYM table_ident opt_derived_column_list {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->sql_command= SQLCOM_CREATE_VIEW;
            
            if (!lex->query_block->add_table_to_list(thd, $3, nullptr,
                                                    TL_OPTION_UPDATING,
                                                    TL_IGNORE,
                                                    MDL_EXCLUSIVE))
              MYSQL_YYABORT;
            lex->query_tables->open_strategy= Table_ref::OPEN_STUB;
            thd->parsing_system_view= lex->query_tables->is_system_view;
            if ($4.size())
            {
              for (auto column_alias : $4)
              {
                
                if (check_column_name(column_alias.str))
                {
                  my_error(ER_WRONG_COLUMN_NAME, MYF(0), column_alias.str);
                  MYSQL_YYABORT;
                }
              }
              
              void *rawmem= thd->memdup(&($4), sizeof($4));
              if (!rawmem)
                MYSQL_YYABORT; 
              lex->query_tables->
                set_derived_column_names(static_cast<Create_col_name_list* >(rawmem));
            }
          }AS view_query_block 
;

view_query_block:
query_expression_with_opt_locking_clauses view_check_option {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            lex->parsing_options.allows_variable= false;
            lex->parsing_options.allows_select_into= false;

            
            SQL_I_List<Table_ref> save_list;
            Query_block * const save_query_block= Select;
            save_query_block->m_table_list.save_and_clear(&save_list);

            CONTEXTUALIZE_VIEW($1);

            
            save_query_block->m_table_list.push_front(&save_list);

            Lex->create_view_check= $2;

            
            const size_t len= @2.cpp.end - @1.cpp.start;
            lex->create_view_query_block.str=
              static_cast<char *>(thd->memdup(@1.cpp.start, len));
            lex->create_view_query_block.length= len;
            trim_whitespace(thd->charset(), &lex->create_view_query_block);

            lex->parsing_options.allows_variable= true;
            lex->parsing_options.allows_select_into= true;
          }
;

view_check_option:
%empty { $$= VIEW_CHECK_NONE; }
|WITH CHECK_SYM OPTION { $$= VIEW_CHECK_CASCADED; }
|WITH CASCADED CHECK_SYM OPTION { $$= VIEW_CHECK_CASCADED; }
|WITH LOCAL_SYM CHECK_SYM OPTION { $$= VIEW_CHECK_LOCAL; }
;

trigger_action_order:
FOLLOWS_SYM { $$= TRG_ORDER_FOLLOWS; }
|PRECEDES_SYM { $$= TRG_ORDER_PRECEDES; }
;

trigger_follows_precedes_clause:
%empty {
              $$.ordering_clause= TRG_ORDER_NONE;
              $$.anchor_trigger_name= NULL_CSTR;
            }
|trigger_action_order ident_or_text {
              $$.ordering_clause= $1;
              $$.anchor_trigger_name= { $2.str, $2.length };
            }
;

trigger_tail:
TRIGGER_SYM opt_if_not_exists sp_name trg_action_time trg_event ON_SYM table_ident FOR_SYM EACH_SYM ROW_SYM trigger_follows_precedes_clause {                               
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            if (lex->sphead)
            {
              my_error(ER_SP_NO_RECURSIVE_CREATE, MYF(0), "TRIGGER");
              MYSQL_YYABORT;
            }

            sp_head *sp= sp_start_parsing(thd, enum_sp_type::TRIGGER, $3);

            if (!sp)
              MYSQL_YYABORT;

            sp->m_trg_chistics.action_time= (enum enum_trigger_action_time_type) $4;
            sp->m_trg_chistics.event= (enum enum_trigger_event_type) $5;
            sp->m_trg_chistics.ordering_clause= $11.ordering_clause;
            sp->m_trg_chistics.anchor_trigger_name= $11.anchor_trigger_name;

            lex->stmt_definition_begin= @1.cpp.start;
            lex->create_info->options= $2 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
            lex->ident.str= const_cast<char *>(@7.cpp.start);
            lex->ident.length= @9.cpp.start - @7.cpp.start;

            lex->sphead= sp;
            lex->spname= $3;

            memset(&lex->sp_chistics, 0, sizeof(st_sp_chistics));
            sp->m_chistics= &lex->sp_chistics;

            
            lex->sp_chistics.language = {"SQL",3};

            sp->set_body_start(thd, @11.cpp.end);
          }sp_proc_stmt {                               
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;

            sp_finish_parsing(thd);

            lex->sql_command= SQLCOM_CREATE_TRIGGER;

            if (sp->is_not_allowed_in_function("trigger"))
              MYSQL_YYABORT;

            
            if (!lex->query_block->add_table_to_list(thd, $7,
                                                    nullptr,
                                                    TL_OPTION_UPDATING,
                                                    TL_READ_NO_INSERT,
                                                    MDL_SHARED_NO_WRITE))
              MYSQL_YYABORT;

            Lex->m_sql_cmd= new (YYTHD->mem_root) Sql_cmd_create_trigger();
          }
;

udf_tail:
AGGREGATE_SYM FUNCTION_SYM opt_if_not_exists ident RETURNS_SYM udf_type SONAME_SYM TEXT_STRING_sys {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            if (is_native_function($4))
            {
              if($3)
              {
                
                my_error(ER_IF_NOT_EXISTS_UNSUPPORTED_UDF_NATIVE_FCT_NAME_COLLISION, MYF(0), $4.str);
              }
              else
                my_error(ER_NATIVE_FCT_NAME_COLLISION, MYF(0), $4.str);
              MYSQL_YYABORT;
            }
            lex->sql_command = SQLCOM_CREATE_FUNCTION;
            lex->udf.type= UDFTYPE_AGGREGATE;
            lex->stmt_definition_begin= @2.cpp.start;
            lex->create_info->options= $3 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
            lex->udf.name = $4;
            lex->udf.returns=(Item_result) $6;
            lex->udf.dl=$8.str;
          }
|FUNCTION_SYM opt_if_not_exists ident RETURNS_SYM udf_type SONAME_SYM TEXT_STRING_sys {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            if (is_native_function($3))
            {
              if($2)
              {
                
                my_error(ER_IF_NOT_EXISTS_UNSUPPORTED_UDF_NATIVE_FCT_NAME_COLLISION, MYF(0), $3.str);
              }
              else
                my_error(ER_NATIVE_FCT_NAME_COLLISION, MYF(0), $3.str);
              MYSQL_YYABORT;
            }
            lex->sql_command = SQLCOM_CREATE_FUNCTION;
            lex->udf.type= UDFTYPE_FUNCTION;
            lex->stmt_definition_begin= @1.cpp.start;
            lex->create_info->options= $2 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
            lex->udf.name = $3;
            lex->udf.returns=(Item_result) $5;
            lex->udf.dl=$7.str;
          }
;

sf_tail:
FUNCTION_SYM opt_if_not_exists sp_name '(' {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            lex->stmt_definition_begin= @1.cpp.start;
            lex->spname= $3;

            if (lex->sphead)
            {
              my_error(ER_SP_NO_RECURSIVE_CREATE, MYF(0), "FUNCTION");
              MYSQL_YYABORT;
            }


            sp_head *sp= sp_start_parsing(thd, enum_sp_type::FUNCTION, lex->spname);

            if (!sp)
              MYSQL_YYABORT;

            lex->sphead= sp;
            lex->create_info->options= $2 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;

            sp->m_parser_data.set_parameter_start_ptr(@4.cpp.end);
          }sp_fdparam_list ')' {                     
            Lex->sphead->m_parser_data.set_parameter_end_ptr(@7.cpp.start);
          }RETURNS_SYM type opt_collate {                     
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;

            CONTEXTUALIZE($10);
            enum_field_types field_type= $10->type;
            const CHARSET_INFO *cs= $10->get_charset();
            if (merge_sp_var_charset_and_collation(cs, $11, &cs))
              MYSQL_YYABORT;

            
            if ((field_type == MYSQL_TYPE_STRING || field_type == MYSQL_TYPE_VARCHAR)
                && ($10->get_type_flags() & BINCMP_FLAG))
            {
              my_error(ER_NOT_SUPPORTED_YET, MYF(0), "return value collation");
              MYSQL_YYABORT;
            }

            if (sp->m_return_field_def.init(YYTHD, "", field_type,
                                            $10->get_length(), $10->get_dec(),
                                            $10->get_type_flags(), nullptr, nullptr, &NULL_CSTR, nullptr,
                                            $10->get_interval_list(),
                                            cs ? cs : YYTHD->variables.collation_database,
                                            $11 != nullptr, $10->get_uint_geom_type(),
                                            nullptr, nullptr, {},
                                            dd::Column::enum_hidden_type::HT_VISIBLE))
            {
              MYSQL_YYABORT;
            }

            if (prepare_sp_create_field(YYTHD,
                                        &sp->m_return_field_def))
              MYSQL_YYABORT;

            memset(&lex->sp_chistics, 0, sizeof(st_sp_chistics));

            
            lex->sp_chistics.language = {"SQL",3};
          }sp_c_chistics {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            lex->sphead->m_chistics= &lex->sp_chistics;
            lex->sphead->set_body_start(thd, yylloc.cpp.start);
          }stored_routine_body {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            if (sp->is_not_allowed_in_function("function"))
              MYSQL_YYABORT;

            lex->sql_command= SQLCOM_CREATE_SPFUNCTION;

            if (sp->is_sql() && !(sp->m_flags & sp_head::HAS_RETURN)) {
              my_error(ER_SP_NORETURN, MYF(0), sp->m_qname.str);
              MYSQL_YYABORT;
            }

            if (is_native_function(sp->m_name))
            {
              
              push_warning_printf(thd,
                                  Sql_condition::SL_NOTE,
                                  ER_NATIVE_FCT_NAME_COLLISION,
                                  ER_THD(thd, ER_NATIVE_FCT_NAME_COLLISION),
                                  sp->m_name.str);
            }
          }
;

routine_string:
TEXT_STRING_literal 
|DOLLAR_QUOTED_STRING_SYM 

stored_routine_body:
AS routine_string {
            sp_head *sp = Lex->sphead;
            if (sp->is_sql()) {
               YYTHD->syntax_error();
               MYSQL_YYABORT;
            }
            sp->code = to_lex_cstring($2);

            THD *thd = YYTHD;
            sp_finish_parsing(thd);
          }
|sp_proc_stmt {
            if (!Lex->sphead->is_sql()) {
              YYTHD->syntax_error();
              MYSQL_YYABORT;
            }

            THD *thd = YYTHD;
            sp_finish_parsing(thd);
          }
;

sp_tail:
PROCEDURE_SYM opt_if_not_exists sp_name {                     
            THD *thd= YYTHD;
            LEX *lex= Lex;

            if (lex->sphead)
            {
              my_error(ER_SP_NO_RECURSIVE_CREATE, MYF(0), "PROCEDURE");
              MYSQL_YYABORT;
            }

            lex->stmt_definition_begin= @1.cpp.start;

            sp_head *sp= sp_start_parsing(thd, enum_sp_type::PROCEDURE, $3);

            if (!sp)
              MYSQL_YYABORT;

            lex->sphead= sp;
            lex->create_info->options= $2 ? HA_LEX_CREATE_IF_NOT_EXISTS : 0;
          }'(' {                     
            Lex->sphead->m_parser_data.set_parameter_start_ptr(@5.cpp.end);
          }sp_pdparam_list ')' {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            lex->sphead->m_parser_data.set_parameter_end_ptr(@8.cpp.start);
            memset(&lex->sp_chistics, 0, sizeof(st_sp_chistics));

            
            lex->sp_chistics.language = {"SQL",3};
          }sp_c_chistics {                     
            THD *thd= YYTHD;
            LEX *lex= thd->lex;

            lex->sphead->m_chistics= &lex->sp_chistics;
            lex->sphead->set_body_start(thd, yylloc.cpp.start);
          }stored_routine_body {                     
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_CREATE_PROCEDURE;
          }
;

xa:
XA_SYM begin_or_start xid opt_join_or_resume {
            Lex->sql_command = SQLCOM_XA_START;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_xa_start($3, $4);
          }
|XA_SYM END xid opt_suspend {
            Lex->sql_command = SQLCOM_XA_END;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_xa_end($3, $4);
          }
|XA_SYM PREPARE_SYM xid {
            Lex->sql_command = SQLCOM_XA_PREPARE;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_xa_prepare($3);
          }
|XA_SYM COMMIT_SYM xid opt_one_phase {
            Lex->sql_command = SQLCOM_XA_COMMIT;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_xa_commit($3, $4);
          }
|XA_SYM ROLLBACK_SYM xid {
            Lex->sql_command = SQLCOM_XA_ROLLBACK;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_xa_rollback($3);
          }
|XA_SYM RECOVER_SYM opt_convert_xid {
            Lex->sql_command = SQLCOM_XA_RECOVER;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_xa_recover($3);
          }
;

opt_convert_xid:
%empty { $$= false; }
|CONVERT_SYM XID_SYM { $$= true; }

xid:
text_string {
            MYSQL_YYABORT_UNLESS($1->length() <= MAXGTRIDSIZE);
            XID *xid;
            if (!(xid= (XID *)YYTHD->alloc(sizeof(XID))))
              MYSQL_YYABORT;
            xid->set(1L, $1->ptr(), $1->length(), nullptr, 0);
            $$= xid;
          }
|text_string ',' text_string {
            MYSQL_YYABORT_UNLESS($1->length() <= MAXGTRIDSIZE &&
                                 $3->length() <= MAXBQUALSIZE);
            XID *xid;
            if (!(xid= (XID *)YYTHD->alloc(sizeof(XID))))
              MYSQL_YYABORT;
            xid->set(1L, $1->ptr(), $1->length(), $3->ptr(), $3->length());
            $$= xid;
          }
|text_string ',' text_string ',' ulong_num {
            
            bool format_id_overflow_detected= ($5 > LONG_MAX);

            MYSQL_YYABORT_UNLESS($1->length() <= MAXGTRIDSIZE &&
                                 $3->length() <= MAXBQUALSIZE
                                 && !format_id_overflow_detected);

            XID *xid;
            if (!(xid= (XID *)YYTHD->alloc(sizeof(XID))))
              MYSQL_YYABORT;
            xid->set($5, $1->ptr(), $1->length(), $3->ptr(), $3->length());
            $$= xid;
          }
;

begin_or_start:
BEGIN_SYM {}
|START_SYM {}
;

opt_join_or_resume:
%empty { $$= XA_NONE;        }
|JOIN_SYM { $$= XA_JOIN;        }
|RESUME_SYM { $$= XA_RESUME;      }
;

opt_one_phase:
%empty { $$= XA_NONE;        }
|ONE_SYM PHASE_SYM { $$= XA_ONE_PHASE;   }
;

opt_suspend:
%empty { $$= XA_NONE;        }
|SUSPEND_SYM { $$= XA_SUSPEND;     }
|SUSPEND_SYM FOR_SYM MIGRATE_SYM { $$= XA_FOR_MIGRATE; }
;

install_option_type:
%empty { $$=OPT_GLOBAL; }
|GLOBAL_SYM { $$=OPT_GLOBAL; }
|PERSIST_SYM { $$=OPT_PERSIST; }
;

install_set_rvalue:
expr 
|ON_SYM {
            $$= NEW_PTN Item_string(@$, "ON", 2, system_charset_info);
          }
;

install_set_value:
install_option_type lvalue_variable equal install_set_rvalue {
          $$ = NEW_PTN PT_install_component_set_element {$1, $2, $4};
        }
;

install_set_value_list:
install_set_value {
            $$ = NEW_PTN List<PT_install_component_set_element>;
            if (!$$)
              MYSQL_YYABORT; 
            if ($$->push_back($1))
              MYSQL_YYABORT; 
          }
|install_set_value_list ',' install_set_value {
            $$ = $1;
            if ($$->push_back($3))
              MYSQL_YYABORT; 
          }
;

opt_install_set_value_list:
%empty {
            $$ = NEW_PTN List<PT_install_component_set_element>;
          }
|SET_SYM install_set_value_list { $$ = $2; }
;

install_stmt:
INSTALL_SYM PLUGIN_SYM ident SONAME_SYM TEXT_STRING_sys {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_INSTALL_PLUGIN;
            lex->m_sql_cmd= new (YYMEM_ROOT) Sql_cmd_install_plugin(to_lex_cstring($3), $5);
            $$ = nullptr;
          }
|INSTALL_SYM COMPONENT_SYM TEXT_STRING_sys_list opt_install_set_value_list {
            $$ = NEW_PTN PT_install_component(@$, YYTHD, $3, $4);
          }
;

uninstall:
UNINSTALL_SYM PLUGIN_SYM ident {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_UNINSTALL_PLUGIN;
            lex->m_sql_cmd= new (YYMEM_ROOT) Sql_cmd_uninstall_plugin(to_lex_cstring($3));
          }
|UNINSTALL_SYM COMPONENT_SYM TEXT_STRING_sys_list {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_UNINSTALL_COMPONENT;
            lex->m_sql_cmd= new (YYMEM_ROOT) Sql_cmd_uninstall_component($3);
          }
;

TEXT_STRING_sys_list:
TEXT_STRING_sys {
            $$.init(YYTHD->mem_root);
            if ($$.push_back($1))
              MYSQL_YYABORT; 
          }
|TEXT_STRING_sys_list ',' TEXT_STRING_sys {
            $$= $1;
            if ($$.push_back($3))
              MYSQL_YYABORT; 
          }
;

import_stmt:
IMPORT TABLE_SYM FROM TEXT_STRING_sys_list {
            LEX *lex= Lex;
            lex->m_sql_cmd=
              new (YYTHD->mem_root) Sql_cmd_import_table($4);
            if (lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
            lex->sql_command= SQLCOM_IMPORT;
          }
;

clone_stmt:
CLONE_SYM LOCAL_SYM DATA_SYM DIRECTORY_SYM opt_equal TEXT_STRING_filesystem {
            Lex->sql_command= SQLCOM_CLONE;
            Lex->m_sql_cmd= NEW_PTN Sql_cmd_clone(to_lex_cstring($6));
            if (Lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
          }
|CLONE_SYM INSTANCE_SYM FROM user ':' ulong_num IDENTIFIED_SYM BY TEXT_STRING_sys opt_datadir_ssl {
            Lex->sql_command= SQLCOM_CLONE;
            
            if (@6.raw.start - @4.raw.end != 1) {
              YYTHD->syntax_error_at(@5);
              MYSQL_YYABORT;
            }
            $4->first_factor_auth_info.auth = to_lex_cstring($9);
            $4->first_factor_auth_info.uses_identified_by_clause = true;
            Lex->contains_plaintext_password= true;

            Lex->m_sql_cmd= NEW_PTN Sql_cmd_clone($4, $6, to_lex_cstring($10));

            if (Lex->m_sql_cmd == nullptr)
              MYSQL_YYABORT;
          }
;

opt_datadir_ssl:
opt_ssl {
            $$= null_lex_str;
          }
|DATA_SYM DIRECTORY_SYM opt_equal TEXT_STRING_filesystem opt_ssl {
            $$= $4;
          }
;

opt_ssl:
%empty {
            Lex->ssl_type= SSL_TYPE_NOT_SPECIFIED;
          }
|REQUIRE_SYM SSL_SYM {
            Lex->ssl_type= SSL_TYPE_SPECIFIED;
          }
|REQUIRE_SYM NO_SYM SSL_SYM {
            Lex->ssl_type= SSL_TYPE_NONE;
          }
;

resource_group_types:
USER { $$= resourcegroups::Type::USER_RESOURCE_GROUP; }
|SYSTEM_SYM { $$= resourcegroups::Type::SYSTEM_RESOURCE_GROUP; }
;

opt_resource_group_vcpu_list:
%empty {
            
            $$= NEW_PTN Mem_root_array<resourcegroups::Range>(YYMEM_ROOT);
            if ($$ == nullptr)
              MYSQL_YYABORT;
          }
|VCPU_SYM opt_equal vcpu_range_spec_list { $$= $3; }
;

vcpu_range_spec_list:
vcpu_num_or_range {
            resourcegroups::Range r($1.start, $1.end);
            $$= NEW_PTN Mem_root_array<resourcegroups::Range>(YYMEM_ROOT);
            if ($$ == nullptr || $$->push_back(r))
              MYSQL_YYABORT;
          }
|vcpu_range_spec_list opt_comma vcpu_num_or_range {
            resourcegroups::Range r($3.start, $3.end);
            $$= $1;
            if ($$ == nullptr || $$->push_back(r))
              MYSQL_YYABORT;
          }
;

vcpu_num_or_range:
NUM {
            auto cpu_id= my_strtoull($1.str, nullptr, 10);
            $$.start= $$.end=
              static_cast<resourcegroups::platform::cpu_id_t>(cpu_id);
            assert($$.start == cpu_id); 
          }
|NUM '-' NUM {
            auto start= my_strtoull($1.str, nullptr, 10);
            $$.start= static_cast<resourcegroups::platform::cpu_id_t>(start);
            assert($$.start == start); 

            auto end= my_strtoull($3.str, nullptr, 10);
            $$.end= static_cast<resourcegroups::platform::cpu_id_t>(end);
            assert($$.end == end); 
          }
;

signed_num:
NUM { $$= static_cast<int>(my_strtoll($1.str, nullptr, 10)); }
|'-' NUM { $$= -static_cast<int>(my_strtoll($2.str, nullptr, 10)); }
;

opt_resource_group_priority:
%empty { $$.is_default= true; }
|THREAD_PRIORITY_SYM opt_equal signed_num {
            $$.is_default= false;
            $$.value= $3;
          }
;

opt_resource_group_enable_disable:
%empty { $$.is_default= true; }
|ENABLE_SYM {
            $$.is_default= false;
            $$.value= true;
          }
|DISABLE_SYM {
            $$.is_default= false;
            $$.value= false;
          }
;

opt_force:
%empty { $$= false; }
|FORCE_SYM { $$= true; }
;

json_attribute:
TEXT_STRING_sys {
            if ($1.str[0] != '\n') {
              size_t eoff = 0;
              std::string emsg;
              if (!is_valid_json_syntax($1.str, $1.length, &eoff, &emsg,
                  JsonDepthErrorHandler)) {
                my_error(ER_INVALID_JSON_ATTRIBUTE, MYF(0),
                         emsg.c_str(), eoff, $1.str+eoff);
                MYSQL_YYABORT;
              }
            }
            $$ = to_lex_cstring($1);
          }

