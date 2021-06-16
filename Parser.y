%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"
  #define MAX 64

  int yylex(void);
  int yyparse(void);
  int yyerror(char *m);
  void warning(char *s);

  extern int yylineno;

  int out_lin=0;
  struct parametriFunkcije
  {
      unsigned id; //id funkcije
      unsigned tipovi[MAX]; // niz tipova argumenata
  };

  int redni_br_funkcije = 0;
  int brojac_parametara = 0;
  int brojac_argumenata = 0;
  int tip_argumenta_pomocna=0;
  int brojac_labela=-1;
  FILE *output;

  struct parametriFunkcije nizStrukturaParametara[MAX];

  char char_buffer[CHAR_BUFFER_LENGTH];
  int broj_gresaka = 0;
  int broj_upozorenja = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;

  int tip_pomocna = 0;
  bool return_pomocna=0;
  int br_parametara_int=0;
  int br_parametara_uint=0;
  int redni_br_parametara=0;

  int id_inc_promenljive=0;
  int inc_promenljive[MAX];
  int uslovni_brojac_labela=0;
  int brojac_dodatni_zad1=0;
  int niz_dodatni_zad1[MAX];
  int maks_for=-1;
  int for_brojac_ugnjezdenih=0;

  void PushArgumenata();
  int niz_indeksa_argumenata[MAX];

%}

%union  
{ 
  int i;
  char *s;
}

%token _FUN
%token FUNZAG
%token OZAG
%token ZZAG
%token TACKA
%token ZAREZ
%token TACKAZAREZ
%token <s> _INT
%token <s> _UINT
%token <s> _FLOAT
%token <s> _BOOL
%token <s> ID
%token <i> TIP
%token <i> ROP
%token <i> AOP
%token DOP
%token IF
%token IF_OZAG
%token IF_ZZAG
%token INCR
%token DECR
%token IZLAZ
%token BRANCH
%token FIRST
%token SECOND
%token THIRD
%token OTHERWISE
%token ARROW
%token FOR
%token DOWNTO
%token TO
%token OVITICASTA
%token ZVITICASTA
%token DVOTACKA



%type <i> skup_delova_izraza 
%type <i>  broj 
%type <i>  deo_izraza 
%type <i>  skup_relacionih_izraza
%type <i>  parametar
%type <i>  parametar_sa
%type <i> poziv_funkcije
%type <i> argument
%type <i> poziv_funkcije_void
%type <i> format
%type <i> format_argumenta
%type <i> if_deo
%type <i> izlaz
%type <i> uslovni_izraz
%type <i> pomocni_uslovni_izraz
%type <i> smer






%nonassoc ONLY_IF
%nonassoc ELSE

%%
  
  program
  : lista_globalnih lista_funkcija
    {
        if(lookup_symbol("v_Main", FUN) == NO_INDEX)
        err("Nedefinisana funkcija 'Main'");
    }
  ;

   lista_funkcija
   : funkcija
   | lista_funkcija funkcija
   ;



  funkcija
  : TIP _FUN ID 
  {
        fun_idx = lookup_symbol($3,FUN);
        if(fun_idx == NO_INDEX)
        {
          fun_idx = insert_symbol($3, FUN, $1, NO_ATR, NO_ATR,NO_ATR,NO_ATR);
          nizStrukturaParametara[redni_br_funkcije].id = fun_idx;
        }
        else
          err("Redefinicija funkcije %s", $3);



       if(strcmp(get_name(fun_idx), "v_Main") == 0)
        {
          code("\nmain:");
          code("\n\t\tPUSH\t%%14");
          code("\n\t\tMOV \t%%15,%%14");
        }
        else
        {
          code("\n%s:", $3);
          code("\n\t\tPUSH\t%%14");
          code("\n\t\tMOV \t%%15,%%14");
        }

   }
    FUNZAG parametar FUNZAG telo
    {
      for(int i= fun_idx+1; i<=get_last_element();i++)
        if(get_kind(i)==VAR)
          if(get_atr2(i)==0)
            /*printf("Vrednost za atr2 = %d na indeksu %d\n",get_atr2(i),i);*/
          err("Promenljiva  %s je definisana ali joj vrednost nikad nije dodeljena",get_name(i));
      if(return_pomocna==0 && $1!=VOID)
        err("Funkcija %s je tipa int i unsigned i treba da vrati vrednost!",$3);
        clear_symbols(fun_idx + 1);
        var_num = 0;
        return_pomocna=0;
        redni_br_parametara=0;

        br_parametara_int=0;
        br_parametara_uint=0;

        redni_br_funkcije++;
        brojac_parametara=0;

     if(strcmp(get_name(fun_idx), "v_Main") == 0)
      {
        code("\n@main_exit:");
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }
      else
      {
        code("\n@%s_exit:", $3);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }

    }
  ;

  parametar
  : 
    {
      set_atr1(fun_idx,0);
      set_atr3(fun_idx,0);
    }
  | parametar_sa
  ;

  parametar_sa
  : TIP ID 
    {
      if($1==VOID)
        err("Parametar %s ne sme biti tipa void",$2);

      if(lookup_symbol($2,PAR) == NO_INDEX)
      {
        if($1==INT)
        {

          nizStrukturaParametara[redni_br_funkcije].tipovi[brojac_parametara]=$1;
           insert_symbol($2,PAR,$1,++redni_br_parametara,NO_ATR,NO_ATR,NO_ATR);
            set_atr1(fun_idx,++br_parametara_int
              );
            set_atr2(fun_idx,$1);
        }
        else if($1==UINT)
        {
          nizStrukturaParametara[redni_br_funkcije].tipovi[brojac_parametara]=$1;
           insert_symbol($2,PAR,$1,++redni_br_parametara,NO_ATR,NO_ATR,NO_ATR);
            set_atr3(fun_idx,++br_parametara_uint
              );
            set_atr4(fun_idx,$1);
        }
        brojac_parametara++;
      }
      else
        err("Dati parametar vec postoji %s",$2);
     }
    | parametar_sa ZAREZ TIP ID
    {
      if($3==VOID)
        err("Parametar %s ne sme biti tipa void",$4);
      
      if(lookup_symbol($4,PAR)== NO_INDEX)
      {
        if($3==INT)
        {
           insert_symbol($4,PAR,$3,++redni_br_parametara,NO_ATR,NO_ATR,NO_ATR);
            nizStrukturaParametara[redni_br_funkcije].tipovi[brojac_parametara]=$3;
            set_atr1(fun_idx,++br_parametara_int
              );
            set_atr2(fun_idx,$3);
        }
        else
        {
           
            insert_symbol($4,PAR,$3,++redni_br_parametara,NO_ATR,NO_ATR,NO_ATR);
            nizStrukturaParametara[redni_br_funkcije].tipovi[brojac_parametara]=$3;
            set_atr3(fun_idx,++br_parametara_uint
              );
            set_atr4(fun_idx,$3);
        }
        brojac_parametara++;
      }
      else
        err("Dati parametar vec postoji %s",$4);
    }
  ;

  
  telo
  : OZAG lista_promenljivih 
  {
      if(var_num)
          code("\n\t\tSUBS \t%%15,$%d,%%15",4*var_num);
        if(strcmp(get_name(fun_idx), "Main") == 0)
      code("\n@main_body:");
    else
      code("\n@%s_body:", get_name(fun_idx));
  }
  lista_izraza ZZAG
  ;

   lista_globalnih
   : 
   | lista_globalnih globalna
   ;
   
   globalna
   : TIP ID TACKAZAREZ
      {
         if(lookup_symbol($2,GVAR)==NO_INDEX)
            insert_symbol($2,GVAR,$1,var_num++,NO_ATR,NO_ATR,NO_ATR);
          else
          err("Globalna promenljiva %s vec postoji",$2);

        code("\n%s:",$2);
        code("\n\t\tWORD 1");
        
      }
   ;


  lista_promenljivih
  :
  | lista_promenljivih promenljiva
  ;

  promenljiva
  : TIP { tip_pomocna = $1; } format format_opciono TACKAZAREZ
  ; 

  format
  : ID 
  {
      if(tip_pomocna== VOID)
        err("Promenljiva %s ne sme biti tipa void",$1);
      else
      {
        if(lookup_symbol($1, VAR|PAR) == NO_INDEX)
          insert_symbol($1, VAR, tip_pomocna, ++var_num, NO_ATR,NO_ATR,NO_ATR);
        else
          err("Promenjiva sa datim imenom vec postoji - [%s]", $1);
      }

      niz_dodatni_zad1[brojac_dodatni_zad1]=lookup_symbol($1, VAR|PAR);
      brojac_dodatni_zad1++;
  }
  | format ZAREZ ID
  {
    if(tip_pomocna== VOID)
        err("Promenljiva %s ne sme biti tipa void",$3);
    else
    {
        if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
            insert_symbol($3, VAR, tip_pomocna,++var_num,NO_ATR,NO_ATR,NO_ATR);
          else
            err("Promenjiva sa datim imenom vec postoji - [%s]", $3);


      niz_dodatni_zad1[brojac_dodatni_zad1]=lookup_symbol($3, VAR|PAR);
      brojac_dodatni_zad1++;
    }
  }
  ;

  format_opciono
  :
   | DOP broj
  {
        if(tip_pomocna!=get_type($2))
        err("Nemoguca dodela zbog razlicitih tipova!");

    for(int i=0;i<brojac_dodatni_zad1;i++)
    {
         set_atr2(niz_dodatni_zad1[i],1); /*Postavljanje ID-a na 1*/
         gen_mov($2,niz_dodatni_zad1[i]);
    }

    brojac_dodatni_zad1=0;

  }
  ;


  
  lista_izraza
  : 
  | lista_izraza izraz
  ;

  izraz
  : dodela
  | inkrement
  | dekrement
  | if_izraz
  | grupa_izraza
  | izlaz
  | branch
  | for_izraz
  | poziv_funkcije_void
  ;


  grupa_izraza
  : OZAG lista_izraza ZZAG 
  ;

  uslovni_izraz
  : OZAG skup_relacionih_izraza 
  {

    code("\n\t\t%s\t@USLOVfalse%d", opp_jumps[$2], ++brojac_labela); 

  }
  ZZAG IF pomocni_uslovni_izraz DVOTACKA pomocni_uslovni_izraz
  {
      if(get_type($6)!=get_type($8))
        err("Razliciti tipovi kod uslovnog izraza");
      else
      {
        int registar=take_reg();
        code("\n@USLOVtrue%d:",brojac_labela); 
        gen_mov($6,registar);
        code("\n\t\tJMP\t@USLOVexit%d", brojac_labela); 
        code("\n@USLOVfalse%d:",brojac_labela); 
        gen_mov($8,registar);
        code("\n@USLOVexit%d:",brojac_labela); 
        $$=registar;

      }
  }
  ;

  pomocni_uslovni_izraz
  : ID
  {
      int uslovna_pomocna=lookup_symbol($1,VAR|PAR|GVAR);
      if(uslovna_pomocna==NO_INDEX)
        err("Nije deklarisan pomocni ID za dati uslovni izraz");
      $$=uslovna_pomocna;
  }
  | broj
  ;

  izlaz
  :IZLAZ TACKAZAREZ
    {
        return_pomocna=1;

        if(get_type(fun_idx)==INT || get_type(fun_idx)==UINT)
          warn("Funkcije tipa int i uint treba da vrate neku vrednost");

    }
  | IZLAZ {return_pomocna=1;} skup_delova_izraza TACKAZAREZ
    {
        if(get_type(fun_idx)==VOID)
          err("Funkcija je tipa void i nema povratnu vrednost!");
        else
        {
            if(get_type(fun_idx)!= get_type($3))
            err("Nemoguce je vratiti vrenost zato sto su tipovi nekompatibilni");
        }

        gen_mov($3,FUN_REG);
       if(strcmp(get_name(fun_idx), "v_Main") == 0)
        code("\n\t\tJMP \t@main_exit");
      else
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx));
    }
  ;

  if_izraz
  : if_deo %prec ONLY_IF
 {
      code("\n@exit%d:",$1);
  }
  | if_deo ELSE izraz
  {
      code("\n@exit%d:",$1);
  }
  ;

  if_deo
  : IF IF_OZAG 
  {
  
    $<i>$ = ++brojac_labela;
    code("\n@if%d: ",brojac_labela);

  }
  skup_relacionih_izraza 
  {
      code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3); 
      code("\n@true%d:", $<i>3);
  }
  
  IF_ZZAG izraz
 {
      code("\n\t\tJMP \t@exit%d", $<i>3);
      code("\n@false%d:", $<i>3);
      $$ = $<i>3;
  }

  ;


  skup_relacionih_izraza
  : skup_delova_izraza ROP skup_delova_izraza
    { 
        if(get_type($1) != get_type($3))
          err("Ne moze se primeniti operator");
        $$ = $2+((get_type($1)-1)*RELOP_NUMBER);
        gen_cmp($1,$3);
    }
  ;

  dodela
  : ID DOP skup_delova_izraza TACKAZAREZ
    {
      int id_index = lookup_symbol($1, VAR|PAR|GVAR);
      if(id_index == NO_INDEX)
        err("Nepostojeci ID, nemoguca dodela - [%s]", $1);
      else
        if(get_type(id_index) != get_type($3))
          err("Razliciti tipovi, nemoguca dodela");
      set_atr2(id_index,1);
      gen_mov($3,id_index);
    }
  
  ;

  skup_delova_izraza
  : deo_izraza
  {
      $$=$1;
  }
  | skup_delova_izraza AOP deo_izraza
    {
        if(get_type($1) != get_type($3))
          err("Ne moze se primeniti operator");
       int t1 = get_type($1);    
        code("\n\t\t%s\t", ar_instructions[$2 + ((t1 - 1) * AROP_NUMBER)]);
        gen_sym_name($1);
        code(",");
        gen_sym_name($3);
        code(",");
        free_if_reg($3);
        free_if_reg($1);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);


      for(int i=0;i<id_inc_promenljive;i++)
      {
         // int pomocna_inc =lookup_symbol(get_name(inc_promenljive[i]), VAR|PAR|GVAR);
          int pomocna_inc=inc_promenljive[i];
          int t=get_type(pomocna_inc);
          if(t==1)
            code("\n\t\tADDS\t");
          else
            code("\n\t\tADDU\t");
            gen_sym_name(pomocna_inc);
            code(",");
            code("$1");
            code(",");
            gen_sym_name(pomocna_inc);
      }
      id_inc_promenljive=0;

    }
  ;

  inkrement
  : ID 
   {
        int pomocna = lookup_symbol($1,FUN);
        if(pomocna!=NO_INDEX)
          err("Nemoguce je inkrementirati funkciju %s",$1);
        else
        {
          int id_indx=lookup_symbol($1,VAR|PAR|GVAR);
          if(id_indx == NO_INDEX)
           err("Nepostojeci ID - [%s]", $1);
          
        int t=get_type(id_indx);
        if(t==1)
          code("\n\t\tADDS\t");
        else
          code("\n\t\tADDU\t");
        gen_sym_name(id_indx);
        code(",");
        code("$1");
        code(",");
        gen_sym_name(id_indx);
        }
    } 
  INCR TACKAZAREZ
  ;

  dekrement
  : ID 
   {    
        int pomocna = lookup_symbol($1,FUN);
        if(pomocna!=NO_INDEX)
          err("Nemoguce je dekrementirati funkciju %s",$1);
        else
        {
          int id_indx=lookup_symbol($1,VAR|PAR);
          if(id_indx == NO_INDEX)
           err("Nepostojeci ID - [%s]", $1);

        int t=get_type(id_indx);
        if(t==1)
          code("\n\t\tSUBS\t");
        else
          code("\n\t\tSUBU\t");
        gen_sym_name(id_indx);
        code(",");
        code("$1");
        code(",");
        gen_sym_name(id_indx);

        }
    } 
  DECR TACKAZAREZ
  ;

  deo_izraza
  : broj
  | ID
    {
      $$ = lookup_symbol($1, VAR|PAR|GVAR);
      if($$ == NO_INDEX)
        err("ID ne postoji - [%s]", $1);
    }
  | poziv_funkcije
  {
      $$=take_reg();
      gen_mov(FUN_REG,$$);
  }
  | ID INCR
   {
       $$ = lookup_symbol($1, VAR|PAR|GVAR);
      if($$ == NO_INDEX)
        err("ID ne postoji - [%s]", $1);
      int inc_idx=lookup_symbol($1, VAR|PAR|GVAR);
        inc_promenljive[id_inc_promenljive]=inc_idx;
      id_inc_promenljive++;

    }
  | ID DECR
    {
      $$ = lookup_symbol($1, VAR|PAR|GVAR);
      if($$ == NO_INDEX)
        err("ID ne postoji - [%s]", $1);
    }
  |OZAG skup_delova_izraza ZZAG
    {
      $$ = $2;
    }
  | uslovni_izraz
  {
      $$=$1;
  }
  ;

  poziv_funkcije
  :ID
    { 
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' nije funkcija", $1); //ne postoji je pravilnije ovde 

    }
   OZAG argument ZZAG
    {
        if((get_atr1(fcall_idx)+get_atr3(fcall_idx)) != $4)
        {
          //PROVERA BROJA ARGUMENATA
        printf("Broj argumenata -> %d\n", brojac_argumenata);
        printf("Ocekivano argumenata -> %d\n", get_atr1(fcall_idx) + get_atr3(fcall_idx));
        printf("ATR1 -> %d\n", get_atr1(fcall_idx));
        printf("ATR3 -> %d\n", get_atr3(fcall_idx));
           err("Pogresan broj argumenata prosledjenih funkciji '%s'", 
              get_name(fcall_idx));
        } 

        if(strcmp(get_name(fcall_idx), "v_Main") == 0)
        code("\n\t\t\tCALL\tmain");
        else
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15",$4 * 4);
        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;
        brojac_argumenata=0;
    }
  ;

  poziv_funkcije_void
    :ID
    { 
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' nije funkcija", $1);
        if(get_type(fcall_idx)!= VOID)
          err("Funkcija %s nije tipa void, nemoguc samostalan poziv!",$1);

    }
   OZAG argument ZZAG TACKAZAREZ
    {
        if(get_atr1(fcall_idx)+get_atr3(fcall_idx) != $4)
          err("Pogresan broj argumenata prosledjenih funkciji '%s'", 
              get_name(fcall_idx));
      
        if(strcmp(get_name(fcall_idx), "v_Main") == 0)
        code("\n\t\t\tCALL\tmain");
        else
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15",$4 * 4);
        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;
        brojac_argumenata=0;
    }
  ;

/* 3. DODATNI ZADATAK*/
  branch
  : BRANCH IF_OZAG ID TACKAZAREZ broj ZAREZ broj ZAREZ broj IF_ZZAG 
  {
      if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
              err("BRANCH: Varijabla [%s] mora prethodno biti definisana!", $3);
      else
      {
          int tip = get_type(lookup_symbol($3,VAR|PAR));
          if(tip!=get_type($5) || tip!=get_type($7) || tip!= get_type($9))
            err("BRANCH : Varijaba i konstante nisu istog tipa");
      }
      ++brojac_labela;
      int branch_pomocna=lookup_symbol($3, VAR|PAR);
      code("\nBRANCH%d:",brojac_labela);
      gen_cmp(branch_pomocna,$5);
      code("\n\t\tJEQ\t@PRVI%d",brojac_labela);
      gen_cmp(branch_pomocna,$7);
      code("\n\t\tJEQ\t@DRUGI%d",brojac_labela);
      gen_cmp(branch_pomocna,$9);
      code("\n\t\tJEQ\t@TRECI%d",brojac_labela);

      code("\n\t\tJMP\t@USUPROTNOM%d",brojac_labela);


  }
  FIRST ARROW 
  {
       code("\n@PRVI%d:",brojac_labela);
      

  }
  izraz
  {
       code("\n\t\tJMP\t@BRANCHend%d",brojac_labela);
  }
   SECOND ARROW
  {
      code("\n@DRUGI%d:",brojac_labela);
      
  } 
  izraz 
  {
       code("\n\t\tJMP\t@BRANCHend%d",brojac_labela);
  }
  THIRD ARROW 
  {
        code("\n@TRECI%d:",brojac_labela);

  } izraz 
  {
       code("\n\t\tJMP\t@BRANCHend%d",brojac_labela);
  }OTHERWISE ARROW 
  {
       code("\n@USUPROTNOM%d:",brojac_labela);

  } izraz
  {
       code("\n@BRANCHend%d:",brojac_labela);
  }
  ;
/*2.DODATNI ZADATAK*/
  for_izraz
  : FOR OZAG ID DOP broj smer broj ZZAG
  {   

      ++brojac_labela;
      ++for_brojac_ugnjezdenih;
      if(brojac_labela>maks_for)
        maks_for=brojac_labela;

      if(lookup_symbol($3,VAR|PAR|GVAR)==NO_INDEX)
        err("FOR: Promenljiva %s prethodno nije definisana",$3);
      int tip = get_type(lookup_symbol($3,VAR|PAR|GVAR));
      if(tip !=get_type($5) || tip !=get_type($7))
        err("FOR : Nekompatibilni tipovi literala i promenljive");

      gen_mov($5,lookup_symbol($3,VAR|PAR|GVAR));

      if($6==1)
      {
        code("\n\t\tJMP\t@FORto%d", brojac_labela);
      }
      else if($6==2)
        code("\n\t\tJMP\t@FORdownto%d", brojac_labela);

      code("\n@FORto%d:", brojac_labela);
      gen_cmp(lookup_symbol($3,VAR|PAR|GVAR),$7);
      int t1=get_type(lookup_symbol($3,VAR|PAR|GVAR));
          if(t1==1)
            code("\n\t\tJLTS\t");
          else
            code("\n\t\tJLTU\t");
      code("@FORtacno%d", brojac_labela);
       if(t1==1)
            code("\n\t\tJGES\t");
          else
            code("\n\t\tJGEU\t");
      code("@FORexit%d", brojac_labela);


      code("\n@FORdownto%d:", brojac_labela);
      gen_cmp(lookup_symbol($3,VAR|PAR|GVAR),$7);
      int t2=get_type(lookup_symbol($3,VAR|PAR|GVAR));
          if(t2==1)
            code("\n\t\tJGTS\t");
          else
            code("\n\t\tJGTU\t");
      code("@FORtacno%d", brojac_labela);
       if(t1==1)
            code("\n\t\tJLES\t");
          else
            code("\n\t\tJLEU\t");
      code("@FORexit%d", brojac_labela);



      code("\n@FORtacno%d:", brojac_labela);

  } 
  izraz
  { 
          
        code("\n@FORdalje%d:", brojac_labela); 
        if($6==1)
        {
            int t=get_type(lookup_symbol($3,VAR|PAR|GVAR));
            if(t==1)
             code("\n\t\tADDS\t");
            else
            code("\n\t\tADDU\t");
            gen_sym_name(lookup_symbol($3,VAR|PAR|GVAR));
            code(",");
            code("$1");
            code(",");
            gen_sym_name(lookup_symbol($3,VAR|PAR|GVAR));
            code("\n\t\tJMP\t@FORto%d", brojac_labela);


        }
        else if($6==2)
        {
          int t1=get_type(lookup_symbol($3,VAR|PAR|GVAR));
          if(t1==1)
            code("\n\t\tSUBS\t");
          else
            code("\n\t\tSUBU\t");
            gen_sym_name(lookup_symbol($3,VAR|PAR|GVAR));
            code(",");
            code("$1");
            code(",");
            gen_sym_name(lookup_symbol($3,VAR|PAR|GVAR));
            code("\n\t\tJMP\t@FORdownto%d", brojac_labela);
        }
        code("\n@FORexit%d:", brojac_labela); 
        if(--for_brojac_ugnjezdenih)
          -- brojac_labela;
        else
            brojac_labela=maks_for;
  }
  ;

  smer
  : DOWNTO
  {
      $$=2;
  }
  | TO
  {
      $$=1;
  }
  ;

  argument
  : {$$=0;}
  | format_argumenta
  {
      PushArgumenata();
      //poziva se nakon unetih svih argumenata
  }
  ;

  format_argumenta
  : skup_delova_izraza
  { 
      tip_argumenta_pomocna = get_type($1); //pomocna za tip parametara
    for(int i = 0; i < get_last_element(); i++)
    {
      if(fcall_idx == nizStrukturaParametara[i].id)
      {
        if(nizStrukturaParametara[i].tipovi[brojac_argumenata] !=  tip_argumenta_pomocna)
          err("Pogresan red argumenata u funkciji [%s]", get_name(fcall_idx));
      }
    }


    niz_indeksa_argumenata[brojac_argumenata]=$1;
    brojac_argumenata++; //povecavamo broj argumenata
    free_if_reg($1); 
    $$ = brojac_argumenata;
      
  }
  | format_argumenta ZAREZ skup_delova_izraza 
  {
    tip_argumenta_pomocna = get_type($3); //pomocna za tip parametara
    for(int i = 0; i < get_last_element(); i++)
    {
      if(fcall_idx == nizStrukturaParametara[i].id)
      {
        if(nizStrukturaParametara[i].tipovi[brojac_argumenata] !=  tip_argumenta_pomocna)
          err("Pogresan red argumenata u funkciji [%s]", get_name(fcall_idx));
      }
    }
    
    niz_indeksa_argumenata[brojac_argumenata]=$3;
    brojac_argumenata++;//povecavamo broj argumenata
    free_if_reg($3);
    $$ = brojac_argumenata;
      
  }
  ;


  broj
  : _INT
      {
        $$ = insert_literal($1,INT);
      }
  | _UINT
      {
        $$ =insert_literal($1,UINT);
      }
  | _BOOL
      {
        $$ =insert_literal($1,BOOL);
      }
  | _FLOAT
      {
        $$ =insert_literal($1,FLOAT);
      }
  ;
%%
int yyerror(char *s) 
{ 
  fprintf(stderr, "\nSintaksna greska na liniji [%d] - %s\n", yylineno, s);
  broj_gresaka++;
  return 0; 
} 

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  broj_upozorenja++;
}

void proveraArgumenata()
{
  printf("ID_FUNKCIJE | ARGUMENTI_FUNKCIJE\n");
  printf("--------------------------------\n");
  for(int i = 0; i < get_last_element(); i++)
  {
    if(nizStrukturaParametara[i].id!=0)
      printf("     %d             ", nizStrukturaParametara[i].id);
    for(int j = 0; j < get_last_element(); j++)
      if(nizStrukturaParametara[i].tipovi[j]!=0)
        printf("%d ", nizStrukturaParametara[i].tipovi[j]);
    printf("\n\n");
  }
}

void PushArgumenata()
{
    for(int i=brojac_argumenata;i>=0;i--)
    {
        code("\n\t\t\tPUSH\t");
        gen_sym_name(niz_indeksa_argumenata[i]);
    }
}
int main() {

  int synerr;
  init_symtab();
  output = fopen("output.asm", "w+");


  synerr = yyparse();
 // print_symtab();
  //proveraArgumenata();

  clear_symtab();
  fclose(output);


  if(broj_upozorenja)
    printf("\nBROJ UPOZORENJA: %d \n", broj_upozorenja);
  if(broj_gresaka)
  {
      remove("output.asm");
      printf("\nBROJ GRESAKA: %d \n", broj_gresaka);
  }
    

  if(synerr)
    return -1;
  else
    return broj_gresaka;

}



