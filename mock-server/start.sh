#!/bin/bash
#!/bin/bash

if [ ! -d "sample-stocks" ]; then
    tar xf sample-stocks.zip
fi

pip3 install flask flask-cors pandas

python3 app.py