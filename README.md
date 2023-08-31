# external_fifo_transceiver 
Blok IP służący do komunikacji z external_fifo_interface modułu GEM w ZCU102. Konwertuje odebrane/wysyłane
pakiety na AXI-Stream.

## Foldery
- srcs: pliki źródłowe Verilogu.
- tests: zawiera testy i symulacje poszczególnych modułów bloku IP. Testy zostały napisane w
Pythonie z użyciem [cocotb](https://www.cocotb.org/). Przebiegi czasowe można podejrzeć z użyciem np. GTKwave.
