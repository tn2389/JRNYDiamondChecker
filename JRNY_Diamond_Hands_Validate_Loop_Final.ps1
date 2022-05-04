#SET THESE VARIABLES BEFORE RUNNING
$pathToAheadOfHerdPOAPCSV = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\AheadOfHeardPOAP.csv'
$pathToCurrentHoldersCSV = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\CurrentHolders_5_3_22.csv'
$pathToDiamondHandVerifiedExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandVerified.txt'
$pathToSnapshotErrorExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandSnapshotError.txt'
$pathToTransferCheckExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandTransferCheck.txt'
$pathToFlipperExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandFlipper.txt'
$pathToNearMissExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandNearMiss.txt'
$pathToDiamondHandVerifiedTransferExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandVerifiedTransfer.txt'
$pathToDiamondHandManualVerificationExport = 'C:\Users\Todd\Desktop\Crypto\JRNY_Validate\DiamondHandManualVerification.txt'
$apiKey = "PWFKBXYI5KNDH6W76T6HS34W1N5XTR8QYQ"

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

#Static Variables
$holder = 0
$eligibleTransfer = 0
$potentialTransfer = 0
$counter = 1

#Collect Wallets Eligible For Diamond Hands
$AheadOfHerdPOAPList = Import-Csv -Path $pathToAheadOfHerdPOAPCSV | Select-Object -ExpandProperty Address

#Collect Wallets Of Current Holders
$currentHolderList = Import-Csv -Path $pathToCurrentHoldersCSV | Select-Object -ExpandProperty HolderAddress

foreach($wallet in $currentHolderList){

#Track Total Progress Of Script
Write-Progress -Activity 'Checking Each Wallet For Diamond Hands' -Status "$($counter) out of $($currentHolderList.Count)" -PercentComplete (($counter/$AheadOfHerdPOAPList.Count) * 100)

#Pause 1 Second To Avoid Etherscan API Overload
Start-Sleep 1

#Post Wallet Being Checked
Write-Host "Checking wallet $($wallet):"

#Counter
$n = 0

#Blank Array List
$inArray = New-Object -TypeName 'System.Collections.ArrayList'

#Collect Previous JRNY Club Transaction List From Etherscan
$apiResponse = Invoke-RestMethod -Uri "https://api.etherscan.io/api?module=account&action=tokennfttx&contractaddress=0x0b4B2bA334f476C8F41bFe52A428D6891755554d&address=$wallet&page=1&offset=100&startblock=0&endblock=27025780&sort=asc&apikey=$apiKey"

#Parse Through Previous JRNY Club Transaction List From Etherscan
While($apiResponse.result[$n].blockNumber -gt 0){

#Create Transaction Object
$transaction = @{}
$transaction.timeStamp = $apiResponse.result[$n].timeStamp
$transaction.tokenID = $apiResponse.result[$n].tokenID
$transaction.to = $apiResponse.result[$n].to

$transactionObject = New-Object PSobject -Property $transaction

if($apiResponse.result[$n].to -eq $wallet){

#Add To Token Array If "In" Transaction
$inArray.Add($transactionObject) > $null

}Else{

#Convert UNIX Timestamp To Date/Time
$unixToDateTime = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($apiResponse.result[$n].timeStamp))

#Post Date/Time Token ID Was Transferred Out
Write-Host "You transferred JRNY Club #$($apiResponse.result[$n].tokenID) out of your wallet on $($unixToDateTime) to the wallet address of $($apiResponse.result[$n].to). This token has been removed from your token list.  If this token was transferred to a wallet you own and this wallet now does not qualify for Diamond Hands, please fill out the Google Form for review (if eligible)."

#Remove From Token Array If Transferred Out
for ($i = 0; $i -lt $inArray.Count; $i++){
if($inArray[$i].tokenID -eq $apiResponse.result[$n].tokenID){
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
}elseif(($inArray.count -gt '4') -and ($inArray.count -lt '10')){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "EPIC JRNYER" -NoNewline -ForegroundColor Magenta; Write-Host "!"
}elseif(($inArray.count -gt '9') -and ($inArray.count -lt '20')){
Write-Host ""
Write-Host "You own $($inArray.Count) NFTs and are a " -NoNewline; Write-Host "LEGENDARY JRNYER" -NoNewline -ForegroundColor Yellow; Write-Host "!"
}elseif($inArray.count -gt '19'){
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
$holder++
$wallet | Out-File -FilePath $pathToDiamondHandVerifiedExport -Append
}

#If On List, But Didn't Hold Long Enough (Transfers Back Or Recent Purchases)
elseif(($inArray[0].timeStamp -lt '1638854700') -and !($AheadOfHerdPOAPList.Contains($inArray[0].to))){
Write-Host ""
Write-Host "Snapshot error. To review." -ForegroundColor Yellow
$potentialTransfer++
$wallet | Out-File -FilePath $pathToSnapshotErrorExport -Append
}

#If On List, But Didn't Hold Long Enough (Transfers Back Or Recent Purchases)
elseif(($inArray[0].timeStamp -gt '1638854700') -and ($AheadOfHerdPOAPList.Contains($inArray[0].to))){
Write-Host ""
Write-Host "Sorry! Your wallet address was found in the Diamond Hands NFT list, but the longest held JRNY Club NFT in your wallet has only been held since $((Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($inArray[0].timeStamp)))." -ForegroundColor Yellow
$potentialTransfer++
$wallet | Out-File -FilePath $pathToTransferCheckExport -Append
}

#If On List, But Didn't Hold Any
elseif(($inArray.count -eq '0') -and ($AheadOfHerdPOAPList.Contains($wallet))){
Write-Host ""
Write-Host "Sorry! Your wallet address was found in the Diamond Hands NFT list, but you no longer hold any JRNY Club NFTs in your wallet." -ForegroundColor Yellow
$flipper++
$wallet | Out-File -FilePath $pathToFlipperExport -Append
}

#Not On List And Didn't Hold Long Enough
elseif(($inArray[0].timeStamp -gt '1638854700') -and !($AheadOfHerdPOAPList.Contains($inArray[0].to))){
Write-Host ""
Write-Host "Sorry! Your wallet address was not found in the Diamond Hands NFT list, and the longest held JRNY Club NFT in your wallet has only been held since $((Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($inArray[0].timeStamp))).  You are not ahead of the herd!" -ForegroundColor Yellow
if($inArray[0].timeStamp -lt '1639459500'){
$wallet | Out-File -FilePath $pathToNearMissExport -Append
}
}

#No JRNY Club NFTs Owned
}Else{
Write-Host "Sorry! You do not hold any JRNY Club NFTs, and you are not eligible for the Diamond Hands NFT." -ForegroundColor Yellow
}
Write-Host ""
$counter++
}

Write-Host "There were $($holder) verified Diamond Hands and $($potentialTransfer) potential transfers to verify. Checking potential transfers in 10 seconds."

Start-Sleep 10

<#
Below Portion Of Code Checks Potential Wallet Addresses For Eligible Tokens That Were Transferred Back
#>

Write-Host "Now checking potential transfer wallets for eligible tokens."

$walletCheck = Get-Content -Path $pathToTransferCheckExport

#Progress Counter
$counter = 1

foreach($potentialDiamond in $walletCheck){

#Track Total Progress Of Script
Write-Progress -Activity 'Verifying Transfer Wallets For Eligibility' -Status "$($counter) out of $($walletCheck.Count)" -PercentComplete (($counter/$walletCheck.Count) * 100)

#Pause 1 Second To Avoid Etherscan API Overload
Start-Sleep 1

#Collect Previous JRNY Club Transaction List From Etherscan
$apiResponse = Invoke-RestMethod -Uri "https://api.etherscan.io/api?module=account&action=tokennfttx&contractaddress=0x0b4B2bA334f476C8F41bFe52A428D6891755554d&address=$potentialDiamond&page=1&offset=100&startblock=0&endblock=27025780&sort=asc&apikey=$apiKey"

#Reset Counter
$n = 0

#Default To Not Diamond
$nowDiamond = 0

#Blank Array List
$inArray = New-Object -TypeName 'System.Collections.ArrayList'
$totalEligibleArray = New-Object -TypeName 'System.Collections.ArrayList'

#Parse Through Previous JRNY Club Transaction List From Etherscan
While($apiResponse.result[$n].blockNumber -gt 0){

#Create Transaction Object
$transaction = @{}
$transaction.timeStamp = $apiResponse.result[$n].timeStamp
$transaction.tokenID = $apiResponse.result[$n].tokenID
$transaction.to = $apiResponse.result[$n].to

$transactionObject = New-Object PSobject -Property $transaction

#Add To Total Token Array If Eligible "In" Transaction (In Transaction Before Diamond Cutoff)
if(($apiResponse.result[$n].to -eq $potentialDiamond) -and ($apiResponse.result[$n].timeStamp -lt '1638854700')){
$totalEligibleArray.Add($transactionObject) > $null
}

if($apiResponse.result[$n].to -eq $potentialDiamond){

#Add To Token Array If "In" Transaction
$inArray.Add($transactionObject) > $null

}Else{

#Remove From Token Array If Transferred Out
for ($i = 0; $i -lt $inArray.Count; $i++){
if($inArray[$i].tokenID -eq $apiResponse.result[$n].tokenID){
$inArray.Remove($inArray[$i])
}
}
}
$n++
}

#Display Eligible Tokens (If Any)
if($totalEligibleArray.count -gt 0){
Write-Host "Found eligible tokens in wallet $($totalEligibleArray[0].to)."
Write-Host ""
Write-Host "Eligible Tokens:"
for ($i = 0; $i -lt $totalEligibleArray.Count; $i++){
Write-Host $($totalEligibleArray[$i].tokenID)
}

Write-Host ""

#Display Current Tokens Held
Write-Host "Held Tokens:"
for ($i = 0; $i -lt $inArray.Count; $i++){
Write-Host $($inArray[$i].tokenID)
}

Write-Host ""

#Set Counter
$t = 0

#Check If Held Tokens Exist In Eligible Token Array
while($nowDiamond -ne '1' -and $t -lt $inArray.count){
if($totalEligibleArray.tokenID.Contains($inArray[$t].tokenID)){
$nowDiamond = 1
Write-Host "Held token $($inArray[$t].tokenID) found in Eligible Token List.  Adding $($inArray[$t].to) to Diamond Hand list." -ForegroundColor Green
Write-Host ""
$potentialDiamond | Out-File -FilePath $pathToDiamondHandVerifiedTransferExport -Append
$eligibleTransfer++
}
$t++
}
if($nowDiamond -eq '0'){
Write-Host "Sorry, none of the tokens that you hold match to the tokens that you owned before December 7." -ForegroundColor Yellow
Write-Host ""
$potentialDiamond | Out-File -FilePath $pathToDiamondHandManualVerificationExport -Append
}
}
$counter++
}

Write-Host "There were $($holder) verified Diamond Hands and $($eligibleTransfer) verified transfers."
$totalDiamondHands = $holder + $eligibleTransfer
Write-Host "Total Diamond Hands: $($totalDiamondHands)"
Read-Host "Press any key to exit"

