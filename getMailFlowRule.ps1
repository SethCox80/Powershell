
Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Get-TransportRule | Select-Object Name,state,ImmutableId,priority,comments | format-table

2b72f972-02b2-46db-cfd0-08dafecdefd6