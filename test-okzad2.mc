//RETURN: 11
int Function v_Main ** ** 
(
    int v_a;
    int v_i=0;
    int v_b=2;
    v_a = 4;  
    for (v_i = 5 downto 1)
    	v_a increment;
    	for (v_i = 1 to 3)
    			v_a increment;
    	for (v_i = 2 downto 1)
    			v_a increment;
    return v_a;  
       
)