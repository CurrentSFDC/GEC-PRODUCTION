import {convertHexStringToByteArray, convertyByteArrayToPDFBlob,  convertBase64StringToByteArray, convertBase64StringToBlob} from "c/converter";

export const downloadFileFromBlob = function (blob, fileName = 'file') {
    let fileURL = URL.createObjectURL(blob);
    downloadFile(fileURL,fileName);
}

export const downloadPDFFromHexString = function (hexString, fileName = 'file') {
    let byteArray = convertHexStringToByteArray(hexString);
    let pdfBlob = convertyByteArrayToPDFBlob(byteArray);
    downloadFileFromBlob(pdfBlob, fileName);
}

export const downloadPDFFromBase64String = function (base64String, fileName = 'file') {
    let blob = convertBase64StringToBlob(base64String,'application/pdf');
    downloadFileFromBlob(blob, fileName);
}

export const downloadFromBase64String = function (base64String, fileName = 'file') {
    let blob = convertBase64StringToBlob(base64String);
    downloadFileFromBlob(blob, fileName);
}

export const downloadCSV = function (csv, fileName) {
    let encodedUri = encodeURI(csv);
    downloadFile(encodedUri,fileName);
}

export const downloadFile = function(resourceURI, fileName){
    let anchor = document.createElement('a');
    anchor.setAttribute('href', resourceURI);
    anchor.setAttribute('download', fileName);
    anchor.click();
}