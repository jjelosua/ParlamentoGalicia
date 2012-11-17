package org.civio.galparl.utils;

import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.util.Bytes;

public class JobCommon {

	public static String removeSpecialChars(String input) {
		input = input.toLowerCase();
		input = input.replaceAll("[^a-záéíóú]$", "").replaceAll("^[^a-záéíóú]", "");
		input = input.replaceAll("[\\\"\\”\\-\\)\\!\\?]$|\\.{1,3}", "");
		return input.replaceAll("^[\\\"\\”\\-\\)\\!\\?]", "");
	}

	public static byte[] getColumnFamily(Result row, String prefix) {
		return getColumnFamily(row, prefix, "");
	}
	
	public static byte[] getColumnFamily(Result row, String prefix, String qualifier) {
        return row.getValue(Bytes.toBytes(prefix), Bytes.toBytes(qualifier));			
	}	
	
}
