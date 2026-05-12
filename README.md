# Stock Market Project

## Project Structure

```text
stock-market/
├── frontend/                                <- Flutter app
│   ├── lib/
│   │   ├── main.dart                        <- app entry point
│   │   ├── screens/
│   │   │   ├── login_screen.dart            <- login / signup page
│   │   │   ├── welcome_screen.dart          <- Short welcome page (2 sec)
│   │   │   ├── nav_screen.dart              <- main with navigation control
│   │   │   ├── watchlist_screen.dart        <- 20 monitored stocks (real-time)
│   │   │   ├── wallet_screen.dart           <- owned stocks + fake balance
│   │   │   ├── transaction_screen.dart      <- 
│   │   │   ├── stock_details_screen.dart    <- stock details + current price
│   │   │   ├── history_screen.dart          <- historical data + chart
│   │   │   └── trade_screen.dart            <- buy / sell stock
│   │   ├── providers/
│   │   │   ├── auth_provider.dart           <- login / signup state
│   │   │   ├── stocks_provider.dart         <- watchlist + real-time updates
│   │   │   ├── wallet_provider.dart         <- holdings + balance state
│   │   │   └── history_provider.dart        <- historical data state
│   │   ├── services/
│   │   │   ├── stock_service.dart           <- HTTP calls to mock-server
│   │   │   ├── auth_service.dart            <- login / signup logic
│   │   │   └── wallet_service.dart          <- buy / sell / balance logic
│   │   ├── models/
│   │   │   ├── user.dart                    <- user data model
│   │   │   ├── stock.dart                   <- stock model
│   │   │   ├── holding.dart                 <- wallet holding model
│   │   │   └── transaction.dart             <- buy/sell history model
│   │   ├── widgets/
│   │   │   ├── stock_tile.dart              <- stock item in watchlist
│   │   │   └── stock_chart.dart             <- historical chart widget
│   │   ├── db/
│   │   │   └── local_db.dart                <- SQLite / Hive setup
│   │   │                                       users, holdings, transactions
│   │   └── utils/
│   │       ├── constants.dart               <- mock-server base url, config
│   │       └── formatters.dart              <- price/date formatting
│   ├── pubspec.yaml
│   └── .env
│
├── mock-server/                             <- mock stock data server
│   ├── app.py                               <- Python Flask server
│   ├── Makefile                             <- make run / make stop
│   ├── start.sh                             <- ./start.sh to run
│   ├── requirements.txt
│   ├── sample-stocks/
│   └── utils.py
│
├── docs/
│   ├── audit-notes.md                       <- checklist notes
│   └── chosen-stocks.md                     <- list of 20 monitored stocks
│
└── README.md                                <- project description
```
