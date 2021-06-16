//OPIS: dve globalne promenljive
//RETURN: 202

int v_x;
int v_y;

int Function v_f1**int v_a** 
(
    v_x = v_a;
    return v_x;
)

int Function v_f2**int v_a**
(
    v_y = v_a + v_x;
    return v_y;
)

int Function v_Main** **
(
  int v_a;
  int v_b;
  v_a = v_f1(42);
  v_b = v_f2(17);
  return v_a + v_b + v_x + v_y;
)

