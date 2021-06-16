//RETURN: 4

int Function v_Test** **
(
	int v_m = 1;
	return v_m;
)

int Function v_Main ** ** 
(
    int v_a;
    int v_b=2;
    v_a = 3;     
    ? [v_a < 4]
    (
        v_a = v_a + 1;
    )
    !?
    (
        v_a = v_a - 1;
    )

    return v_a;      
)