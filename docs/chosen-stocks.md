# 20 Chosen Monitored Stocks

Below is the list of 20 companies that we have selected to monitor in our application (these tickers are available in our `mock-server` database):

1. **UNT**
2. **TRNS**
3. **EGP**
4. **PHG**
5. **SVT**
6. **SNE**
7. **JOB**
8. **MDT**
9. **MDC**
10. **NC**
11. **MO**
12. **BPOP**
13. **ALCO**
14. **SPXC**
15. **TRN**
16. **ADM**
17. **GGG**
18. **BAC**
19. **LNC**
20. **PPG**

## Implementation Plan (Flutter)

The list of these symbols will be hardcoded in the `lib/utils/constants.dart` file. The application will request data for only these 20 stocks every 200 milliseconds (5 times per second).
