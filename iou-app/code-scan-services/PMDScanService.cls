public without sharing class PMDScanService {

    public static String parseFileName(String unformattedFileName) {
        Integer indexOfFinalDirectory = unformattedFileName.lastIndexOf('/');
        String trimmedFileName = unformattedFileName.substring(indexOfFinalDirectory + 1);
        return trimmedFileName.remove('.cls').remove('"');
    }
}
