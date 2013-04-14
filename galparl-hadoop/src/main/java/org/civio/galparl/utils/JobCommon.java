package org.civio.galparl.utils;

import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.util.Bytes;

public class JobCommon {

	public static String removeSpecialChars(String input) {
		input = input.toLowerCase();
		input = input.replaceAll("[^a-zA-Z0-9-%áéíóúñ]", "");
		return replaceHyphenAtBeginning(input);
	}

	private static String replaceHyphenAtBeginning(String input) {
		return input.replaceAll("^-", "");
	}

	public static byte[] getColumnFamily(Result row, String prefix) {
		return getColumnFamily(row, prefix, "");
	}
	
	public static byte[] getColumnFamily(Result row, String prefix, String qualifier) {
        return row.getValue(Bytes.toBytes(prefix), Bytes.toBytes(qualifier));			
	}	
	
	public static String toKey(Integer season, String word) {
		return season.toString() + "|" + word;
	}

}
