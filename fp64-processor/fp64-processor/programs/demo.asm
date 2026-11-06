; Demo: compute a^2 - b^2 = (a+b)*(a-b) with a=1.5, b=2.25, then test FLT/BEQ.
        FLD  f1, 0          ; f1 = 1.5
        FLD  f2, 1          ; f2 = 2.25
        FLD  f7, 3          ; f7 = 1.0
        FADD f3, f1, f2     ; 3.75
        FSUB f4, f1, f2     ; -0.75
        FMUL f5, f3, f4     ; -2.8125
        FST  f3, 16
        FST  f4, 17
        FST  f5, 18
        FLT  f6, f1, f2     ; 1.5 < 2.25 -> 1.0
        BEQ  f6, f7, taken  ; taken
        FST  f6, 19         ; (skipped)
taken:  FNEG f8, f5         ; 2.8125
        FABS f9, f5         ; 2.8125
        FXOR f10, f5, f5    ; 0 (bitwise)
        FST  f8, 20
        FST  f9, 21
        FST  f6, 22
        FST  f10, 23
        HALT
