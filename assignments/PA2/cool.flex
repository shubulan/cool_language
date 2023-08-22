/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%option noyywrap
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

%x mcomment
%x scomment
%x string
%x string_error

/*
 * Define names for regular expressions here.
 */

DARROW          =>

DIGIT           [0-9]

INTEGERS        [0-9]+

STRING_CONST    []

OBJECTID        [a-z][a-zA-Z0-9_]*

TYPEID          [A-Z][a-zA-Z0-9_]*
%%



"."             return '.';
"<"             return '<';
"="             return '=';
"+"             return '+';
"-"             return '-';
"*"             return '*';
"/"             return '/';

"("             return '(';
")"             return ')';
"{"             return '{';
"}"             return '}';
";"             return ';';
":"             return ':';
","             return ',';
"@"             return '@';
"~"             return '~';


[ \t\v\r\f]+    /* eat up white space */



"true"      {
  cool_yylval.boolean = true;
  return BOOL_CONST;
}

"false"     {
  cool_yylval.boolean = false;
  return BOOL_CONST;
}

{TYPEID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

{OBJECTID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

\n    curr_lineno++;

{INTEGERS} {
  cool_yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;
}


 /*
  *  Nested comments
  */
"(*"   BEGIN(mcomment);
<mcomment>[^*\n]*  /* eat up all char but * and \n */
<mcomment>"*"+[^*)\n]*  /* eat up * \n */
<mcomment>\n  curr_lineno++;
<mcomment>"*)" BEGIN(INITIAL);
<mcomment><<EOF>> {
  yylval.error_msg = "EOF in comment";
  BEGIN(INITIAL);
  return ERROR;
}

"--"   BEGIN(scomment);
<scomment>[^\n]*  /* eat up all char but \n */
<scomment>[\n]  {
  curr_lineno++;
  BEGIN(INITIAL);
}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
"<-"        { return ASSIGN; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

(?i:class)     {
  return CLASS;
}
(?i:if)        return IF;
(?i:then)      return THEN;
(?i:else)      return ELSE;
(?i:fi)        return FI;
(?i:in)        return IN;
(?i:inherits)  return INHERITS;
(?i:isvoid)    return ISVOID;
(?i:let)       return LET;
(?i:while)     return WHILE;
(?i:loop)      return LOOP;
(?i:pool)      return POOL;
(?i:case)      return CASE;
(?i:esac)      return ESAC;
(?i:new)       return NEW;
(?i:of)        return OF;
(?i:not)       return NOT;


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {
  BEGIN(string);
  string_buf[MAX_STR_CONST - 1] = 0;
  string_buf_ptr = string_buf;
}

<string>[^"\\\n\0] { // normal characters
  int buf_size = MAX_STR_CONST - (string_buf_ptr - string_buf);
  if (yyleng < buf_size) {
    memcpy(string_buf_ptr, yytext, yyleng);
    string_buf_ptr += yyleng;
  } else {
    yylval.error_msg = "String constant too long";
    BEGIN(string_error);
    return ERROR;
  }
}

<string>(\\\n) {
  curr_lineno++;
}

<string>(\\.) {
  int buf_size = MAX_STR_CONST - (string_buf_ptr - string_buf);
  if (1 < buf_size) {
    switch(yytext[1]) {
      case 'b' : *string_buf_ptr++ = '\b'; break;
      case 't' : *string_buf_ptr++ = '\t'; break;
      case 'n' : *string_buf_ptr++ = '\n'; break;
      case 'f' : *string_buf_ptr++ = '\f'; break;
      case '0' : *string_buf_ptr++ = '\0'; break;
      default  : *string_buf_ptr++ = yytext[1]; break;
    }
  } else {
    string_buf_ptr += MAX_STR_CONST;
  }
}

<string>[\n] {
  curr_lineno++;
  yylval.error_msg = "Unterminated string constant";
  BEGIN(INITIAL);
  return ERROR;
}

<string>[\0] {
  yylval.error_msg = "String contains null character";
  BEGIN(INITIAL);
  return ERROR;
}

<string>["] {
  BEGIN(INITIAL);
  *string_buf_ptr = '\0';
  cool_yylval.symbol = stringtable.add_string(string_buf);
  return STR_CONST;
}

<string_error>[^\n"]*
<string_error>[\n]             curr_lineno++;
<string_error>["] {
  BEGIN(INITIAL);
}

 /*
  * error punctuation
  */
(['\[\]\>\\]) {
  yylval.error_msg = strdup(yytext);
  return ERROR;
}

%%
