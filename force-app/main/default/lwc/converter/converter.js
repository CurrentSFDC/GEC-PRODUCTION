export const convertHexStringToBlob = function (hexString, type = 'text/plain') {
    hexString = hexString.slice(2);
    let buf = new ArrayBuffer(hexString.length / 2);
    let byteBuf = new Uint8Array(buf);
    for (let i = 0; i < hexString.length; i += 2) {
        byteBuf[i / 2] = parseInt(hexString.slice(i, i + 2), 16);
    }
    return new Blob([byteBuf], {type: type});
}
export const convertHexStringToPDFBlob = function (hexString) {
    return convertBase64StringToBlob(hexString, 'application/pdf');
}

export const convertBase64StringToBlob = function (b64Data, type = 'text/plain') {
    const byteCharacters = atob(b64Data);
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    const byteArray = new Uint8Array(byteNumbers);
    return new Blob([byteArray], {type: type});
}

export const convertBase64StringToPDFBlob = function (b64Data) {
    return convertBase64StringToBlob(b64Data, 'application/pdf');
}