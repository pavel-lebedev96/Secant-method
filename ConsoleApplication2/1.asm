.386
.MODEL FLAT,C
EXTERN N: DWORD
.DATA
F_A REAL4 ?
F_B REAL4 ?
F_C REAL4 ?
CUR_C REAL4 ?
PREV_C REAL4 ?
CONST_05 REAL4 0.5

.CODE
;вычисление натурального логарифма
;аргумент и результат в ST(0)
NAT_LOG PROC
	FLD1; ST(0)=1, ST(1)=x
	FXCH ST(1); ST(0)=x, ST(1)=1
	FYL2X; ST(0)=log2(x)
	FLDL2E; ST(0)=log2(e), ST(1)=log2(x)
	FDIVP; ST(0)=log2(x)/log2(e)
	RET
NAT_LOG ENDP

;исходная функция
;аргумент и результат в ST(0)
FUNC PROC
	FLD CONST_05; ST(0)=0.5, ST(1)=x
	FADD ST,ST(1); ST(0)=0.5+x, ST(1)=x
	CALL NAT_LOG; ST(0)=ln(x+0.5), ST(1)=x
	FADDP; ST(0)=x+ln(x+0.5)
	FLD CONST_05; ST(0)=0.5, ST(1)=x+ln(x+0.5)
	FSUBP; ST(0)=x+ln(x+0.5)-0.5
	RET
FUNC ENDP

;нахождение пересечения хорды с осью абсцисс
;результат в ST(0)
CALC_C PROC
	FLD REAL4 PTR [EBP+12]; ST(0)=b
	FLD REAL4 PTR [EBP+8]; ST(0)=a, ST(1)=b
	FSUBP; ST(0)=b-a
	FLD F_A; ST(0)=f(a), ST(1)=b-a
	FMULP; ST(0)=f(a)*(b-a)
	FLD F_B; ST(0)=f(b), ST(1)=f(a)*(b-a)
	FLD F_A; ST(0)=f(a), ST(1)=f(B), ST(2)=f(a)*(b-a)
	FSUBP; ST(0)=f(b)-f(a), ST(1)=f(a)*(b-a)
	FDIVP; ST(0)=f(a)*(b-a)/(f(b)-f(a))
	FLD REAL4 PTR [EBP+8]; ST(0)=a, ST(1)=f(a)*(b-a)/(f(b)-f(a))
	FSUBRP; ST(0)=a-f(a)*(b-a)/(f(b)-f(a))
	RET
CALC_C ENDP

;вызываемая подпрограмма
SOLVE PROC
	PUSH EBP
	MOV EBP,ESP
	; a=EBP+8
	; b=EBP+12
	; eps=EBP+16
	FINIT; инициализация сопроцессора
	FLD REAL4 PTR [EBP+8]; ST(0)=a
	CALL FUNC; ST(0)=f(a)
	FSTP F_A; f_a=f(a)
	FLD REAL4 PTR [EBP+12]; ST(0)=b
	CALL FUNC; ST(0)=f(b)
	FSTP F_B; f_b=f(b)
	FLD REAL4 PTR [EBP+8]; ST(0)=a
	FSTP PREV_C; prev_c=a
	FLD REAL4 PTR [EBP+12]; ST(0)=b
	FSTP CUR_C; cur_c=b
METHOD:
	FLD REAL4 PTR [EBP+16]; ST(0)=eps
	FLD CUR_C; ST(0)=cur_c, ST(1)=eps
	FLD PREV_C; ST(0)=prev_c, ST(1)=cur_c, ST(2)=eps
	FSUBP; ST(0)=cur_c-prev_c, ST(1)=eps
	FABS; ST(0)=|cur_c-prev_c|, ST(1)=eps
	FCOMIP ST,ST(1); ST(0)=|cur_c-prev_c|
	FSTP ST
	; если abs(cur_c-prev_c) < eps, то переход END_METHOD
	JC END_METHOD;
	INC N
	FLD CUR_C; ST(0)=cur_c
	FSTP PREV_C; prev_c=cur_c
	CALL CALC_C; ST(0)=a - fa*(b - a) / (fb - fa)
	FST CUR_C; cur_c=a - fa*(b - a) / (fb - fa)
	CALL FUNC; ST(0)=f(c)
	FSTP F_C; f_c=f(c)
	FLDZ; ST(0)=0
	FLD F_A; ST(0)=f_a, ST(1)=0
	FLD F_C; ST(0)=f_c, ST(1)=f_a, ST(2)=0
	FMULP; ST(0)=f_c*f_a, ST(1)=0
	FCOMIP ST,ST(1); ST(0)=0
	FSTP ST
	FLD F_C; ST(0)=f_c
	FLD CUR_C; ST(0)=cur_c, ST(1)=f_c
	;если f(a)*f(c) < 0, то переход LESS
	JC LESS
	FSTP REAL4 PTR [EBP+8]; a=cur_c, ST(0)=f_c
	FSTP F_A; f_a=f_c
	JMP METHOD
LESS:
	FSTP REAL4 PTR [EBP+12]; b=cur_c, ST(0)=f_c
	FSTP F_B; f_b=f_c
	JMP METHOD
END_METHOD:
	FLD CUR_C; ST(0)=CUR_C
	POP EBP
	RET
SOLVE ENDP
END