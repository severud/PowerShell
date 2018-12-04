# https://ccmcache.wordpress.com/2018/11/28/use-powershell-to-discover-new-dell-bios-driver-updates-faster/
# Initialize array of desired models
$models = @("Latitude E6220",
            "Latitude E6330",
            "Latitude E6420",
            "Latitude E6430",
            "OptiPlex 7040",
            "OptiPlex 7060",
            "Optiplex 7010")

# Set URI variables
$baseURI = "http://downloads.dell.com/published/Pages/"
$indexURI = $baseURI + "index.html"

# Set search variables
$sectionID = "Drivers-Category.BI-Type.BIOS"
$datePattern = "*/*/201*"

# Scrape the download index webpage
$dlIndex = Invoke-WebRequest -Uri $indexURI

# Get all links from the webpage
$indexLinks = $dlIndex.Links

# Initialize an empty array to store results
$results = @()

foreach ($model in $models)
{
  # Get the link for the specific model webpage
  $modelLink = $indexLinks | Where-Object {$_.innerHTML -eq $model}

  # Set the URI variable for the specific model webpage
  $modelURI = $baseURI + $modelLink.href

  # Scrape the specific model webpage
  $modelIndex = Invoke-WebRequest -Uri $modelURI

  # Get webpage elements for the desired section ID
  $sectionIndex = $modelIndex.ParsedHtml.getElementsByTagName('div') | Where-Object {$_.id -eq $sectionID}

  # Get innerText values that are like the date pattern
  $releases = ($sectionIndex.getElementsByTagName('TD') | Where-Object {$_.innerText -like $datePattern}).innerText

  # Convert the innerText values to datetime objects
  $releaseDates = $releases | Get-Date

  # Find the object with the most recent date 
  $latestRelease = ($releaseDates | Measure-Object -Maximum).Maximum

  # Populate the results array with the model and most recent release date
  $results += New-Object psobject -Property @{Model=$model; Date=$latestRelease}
}

# Display results and sort by date
$results | Sort-Object -Property Date -Descending
