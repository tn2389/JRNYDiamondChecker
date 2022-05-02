$banner = @'
                 .
                ...
               .....         888                          888
              .......        888                          888
             .........       888                          888
            ...........      888                          888
             .........       88888b.  8888b. 88888b.  .d88888
              .......        888 "88b    "88b888 "88bd88" 888
               .....         888  888.d888888888  888888  888
                ...          888  888888  888888  888Y88b 888
                 .           888  888"Y888888888  888 "Y88888
'@

Write-Host $banner
Write-Host ""

while($loop -ne 1){
#Collect Wallets Eligible For Diamond Hands
$AheadOfHerdPOAPList = Import-Csv -Path C:\Users\Todd\Desktop\Crypto\JRNY_Validate\AheadOfHeardPOAP.csv | Select-Object -ExpandProperty Address

#Collect Input Of Wallet Address
Write-Host "Enter Your Wallet Address:"
$address = Read-Host
Write-Host ""

#Counter
$n = 0

#Blank Array List
$inArray = New-Object -TypeName 'System.Collections.ArrayList'

#Collect Previous Transaction List From Etherscan
$Response = Invoke-RestMethod -Uri "https://api.etherscan.io/api?module=account&action=tokennfttx&contractaddress=0x0b4B2bA334f476C8F41bFe52A428D6891755554d&address=$address&page=1&offset=100&startblock=0&endblock=27025780&sort=asc&apikey=PWFKBXYI5KNDH6W76T6HS34W1N5XTR8QYQ"

#Parse Through Previous Transaction List From Etherscan
While($Response.result[$n].blockNumber -gt 0){

#Create Transaction Object
$item = @{}
$item.timeStamp = $Response.result[$n].timeStamp
$item.tokenID = $Response.result[$n].tokenID
$item.to = $Response.result[$n].to

$Objectname = New-Object PSobject -Property $item

if($Response.result[$n].to -eq $address){

#Add To Token Array If "In" Transaction
$inArray.Add($Objectname) > $null

}Else{

#Convert UNIX Timestamp To Date/Time
$unixToDateTime = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($Response.result[$n].timeStamp))

#Post Date/Time Token ID Was Transferred Out
Write-Host "You transferred JRNY Club #$($Response.result[$n].tokenID) out of your wallet on $($unixToDateTime). This token has been removed from your token list.  If this token was transferred to a wallet you own and this wallet now does not qualify for Diamond Hands, please fill out the Google Form for review (if eligible)."

#Remove From Token Array If Transferred Out
for ($i = 0; $i -lt $inArray.Count; $i++){
if($inArray[$i].tokenID -eq $Response.result[$n].tokenID){
$inArray.Remove($inArray[$i])
}
}
}
$n++
}

#JRNY Club NFTs Owned
if($inArray[0].timeStamp -gt 0){

#Sort Array By Timestamp
$inArray = $inArray | Sort-Object -Property timeStamp

#Count JRNY Club NFTs
if(($inArray.count -gt '1') -and ($inArray.count -lt '3')){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "SPECIAL JRNYER" -NoNewline -ForegroundColor Cyan; Write-Host "!"
}elseif(($inArray.count -gt '2') -and ($inArray.count -lt '5')){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "RARE JRNYER" -NoNewline -ForegroundColor Blue; Write-Host "!"
}elseif(($inArray.count -gt '5') -and ($inArray.count -lt '10')){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "EPIC JRNYER" -NoNewline -ForegroundColor Magenta; Write-Host "!"
}elseif(($inArray.count -gt '10') -and ($inArray.count -lt '20')){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "LEGENDARY JRNYER" -NoNewline -ForegroundColor Yellow; Write-Host "!"
}elseif($inArray.count -gt '20'){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "APEX JRNYER" -NoNewline -ForegroundColor Red; Write-Host "!"
}elseif($inArray[0].to -ne $inArray[1].to){
Write-Host ""
Write-Host "You own 1 NFT and are a " -NoNewline; Write-Host "JRNYER" -NoNewline -ForegroundColor Green; Write-Host "!"
}

Write-Host ""

#List Each JRNY NFT Held And How Long It Has Been Held
foreach($nft in $inArray){

#Convert UNIX Timestamp To Date/Time
$unixToDateTime = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($nft.timeStamp))

$heldDuration = (Get-Date) - $unixToDateTime

Write-Host "You purchased JRNY Club #$($nft.tokenID) on $($unixToDateTime) and have held it for $($heldDuration.Days) day(s)."
}

#If Diamond Hands
if(($inArray[0].timeStamp -lt '1638854700') -and ($AheadOfHerdPOAPList.Contains($inArray[0].to))){
Write-Host ""
Write-Host "Congratulations! Your wallet address was found in the Diamond Hands NFT list, and you hold a JRNY Club NFT that you purchased before December 7 at 5:24 AM UTC.  You are ahead of the herd!" -ForegroundColor Green
}

#If On List, But Didn't Hold
if(($inArray[0].timeStamp -gt '1638854700') -and ($AheadOfHerdPOAPList.Contains($inArray[0].to))){
Write-Host ""
Write-Host "Sorry! Your wallet address was found in the Diamond Hands NFT list, but the longest held JRNY Club NFT in your wallet has only been held since $((Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($inArray[0].timeStamp))).  PUNISH THE FLIPPERS!" -ForegroundColor Yellow
}

#Not On List And Didn't Hold
if(($inArray[0].timeStamp -gt '1638854700') -and !($AheadOfHerdPOAPList.Contains($inArray[0].to))){
Write-Host ""
Write-Host "Sorry! Your wallet address was not found in the Diamond Hands NFT list, and the longest held JRNY Club NFT in your wallet has only been held since $((Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($inArray[0].timeStamp))).  You are not ahead of the herd!" -ForegroundColor Yellow
}

#No JNRY Club NFTs Owned
}Else{
Write-Host "Sorry! You do not hold any JRNY Club NFTs, and you are not eligible for the Diamond Hands NFT." -ForegroundColor Yellow
}

#Loop Until 1 Is Pressed
$loop = Read-Host "Type 1 to exit, or press enter to search again"
}
