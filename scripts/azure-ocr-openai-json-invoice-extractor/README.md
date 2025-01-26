---
plugin: add-to-gallery
---
# Extract Invoice Details from Any File Format Using Azure OCR and OpenAI

## Summary

This sample script integrates Azure's Document Intelligence and OpenAI services to extract from either images or pdfs or embedded images from any unstructured data and to use this script for any other purpose , please change the system prompt in the script.

### **Functionality**

- **Text Extraction**: Utilizes Azure's Document Intelligence Read OCR model to extract text from documents, including PDFs and images.  
- **Data Processing**: Employs Azure OpenAI's GPT models to analyze the extracted text and identify key invoice details, such as **Invoice Number**, **Sales Person**, **Date of Invoice**, **SubTotal**, **Tax**, and **Total**.  
- **JSON Output**: Structures the identified information into a JSON format for streamlined data handling and integration.  

---

## Prerequisites

- **OpenAI API Key**: Create an account [here](https://platform.openai.com/signup/) to obtain the API key.  
- **Document Intelligence API Key**: Create a key in the [Document Intelligence Studio](https://documentintelligence.ai.azure.com/studio/).  
- **Settings**: The settings of the script is part of set Settings-Agreements.json , ensure the script and its settings file are in same location

---

## Settings

```json
{
  "APIKeys": {
    "OpenAI": "<OCRKeyFromAzureOpenAI>",
    "DocumentIntelligence": "<OCRKeyFromADocumentIntelligence>""
  },
  "Endpoints": {
    "OpenAI": "https://<openaiendpoint>.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-08-01-preview",
    "DocumentIntelligence": "https://<docintelligendeendpoint>.cognitiveservices.azure.com"
  },
  "FilePath": "/Users/divyaakula/Documents/VidesoReview/SyntexDemo/AI Builder Document Processing Sample Data/Invoices/Adatum/Train/Adatum 1.pdf",
  "Base64String": null, 
  "OCRVersion": "2024-07-31-preview",
  "ChunkSize": 4194304
}

```

---

## Example Screenshot

![Example Screenshot](assets/output.png)

---

# [PowerShell](#tab/powershell)

```powershell
# A PowerShell script to extract invoice details using Azure OCR and OpenAI.

# Path to your config file
$configFilePath = "Settings-Agreements.json"
if (-not (Test-Path $configFilePath)) {
    throw "Configuration file not found at $configFilePath"
}

# Load configuration from JSON file
$Config = Get-Content -Path $configFilePath | ConvertFrom-Json

# Extract Values from Config
$OpenAI_Key = $Config.APIKeys.OpenAI
$OCR_Key = $Config.APIKeys.DocumentIntelligence
$OCR_Endpoint = $Config.Endpoints.DocumentIntelligence
$OpenAI_Endpoint = $Config.Endpoints.OpenAI
$OCR_Version = $Config.OCRVersion
$FilePath = $Config.FilePath
$Base64String = $Config.Base64String

# Function to Extract Text from PDF/Image Using Azure OCR
function Get-TextFromDocument($Base64String) {
    # Convert Base64 to binary
    $BinaryData = [Convert]::FromBase64String($Base64String)

    # Set OCR request headers
    $Headers = @{
        "Ocp-Apim-Subscription-Key" = $OCR_Key
        "Content-Type" = "application/pdf"  # Change to "image/jpeg" for images
    }

    # Send file to Azure Document Intelligence OCR API
    Invoke-RestMethod -Uri "$OCR_Endpoint/documentintelligence/documentModels/prebuilt-read:analyze?api-version=$OCR_Version" `
                      -Headers $Headers -Method Post -ResponseHeadersVariable HeaderInfo -Body $BinaryData

    if (-not $HeaderInfo) {
        throw "Failed to start OCR process."
    }

    # Extract operation URL
    $OperationUrl = ($HeaderInfo."Operation-Location")[0]
    
    # Poll for result
    Start-Sleep -Seconds 5  # Wait before checking status
    do {
        $Result = Invoke-RestMethod -Uri $OperationUrl -Headers @{ "Ocp-Apim-Subscription-Key" = $OCR_Key }
        $Status = $Result.status
        Start-Sleep -Seconds 2
    } while ($Status -ne "succeeded")

    # Extract recognized text
    $ExtractedText = ($Result.analyzeResult.pages.lines.content) -join " "
    return $ExtractedText
}

# Function to Extract Names Using Azure OpenAI
function Get-Inputs($ExtractedText) {
    # OpenAI Request Payload
    $OpenAI_Request = @{
        messages = @(
            @{ role = "system"; content = "Extract Invoice No, Sales Person, Date Of Invoice, SubTotal, Tax and Total and return in plain json format" }
            @{ role = "user"; content = "Text: $ExtractedText" }
        )
    } | ConvertTo-Json -Depth 3

    # OpenAI Headers
    $OpenAI_Headers = @{
        "api-key" = $OpenAI_Key
        "Content-Type" = "application/json"
    }

    # Call OpenAI API
    $OpenAI_Response = Invoke-RestMethod -Uri "$OpenAI_Endpoint" `
                                         -Method Post -Headers $OpenAI_Headers -Body $OpenAI_Request

    # Extract Names from Response
    $responseContent = $OpenAI_Response.choices[0].message.content 
    # Remove leading and trailing triple backticks and 'json' label
    $jsonString = $responseContent -replace '^```json\s*', '' -replace '\s*```$', ''
    return $jsonString
}

# Function to Process Base64 Document Input
function Get-Data($Base64String) {
    try {
        $Base64String = Convert-Base64String $FilePath
        # Step 1: Extract text using OCR
        $ExtractedText = Get-TextFromDocument -Base64String $Base64String

        # Step 2: Extract Names using OpenAI
        $Names = Get-Inputs -ExtractedText $ExtractedText
        # Step 3: Return as JSON
        return $Names 
    }
    catch {
        return @{ "error" = $_.Exception.Message } | ConvertTo-Json
    }
}

# Function to convert file to Base64 string
function Convert-Base64String($path) {
    $Base64Input = [Convert]::ToBase64String([IO.File]::ReadAllBytes($path))
    return $Base64Input
}

# Example Usage: Provide a Base64 String of a PDF or Image
$Base64Input = ""
# Call the Function
$Result = Get-Data -Base64String $Base64Input
Write-Output $Result

```

[More about OpenAI API](https://learn.microsoft.com/en-us/azure/ai-studio/what-is-ai-studio&wt.mc_id=MVP_366830)
***

## Contributors

| Author(s) | Author(s) |
|-----------|-----------|
| Divya Akula | <https://www.linkedin.com/in/ms-divya-akula/> |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/azure-ocr-openai-json-invoice-extractor" aria-hidden="true" />
