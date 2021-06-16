//RETURN: 2 
int Function v_Main ** ** 
(
    int v_a;
    v_a = 1;  
    branch [v_a; 1, 3, 5]
    first -> v_a increment;
    second -> v_a = v_a + 3;
    third -> v_a= v_a - 5 ;
    otherwise -> v_a= v_a + 4;
    return v_a;  
       
)