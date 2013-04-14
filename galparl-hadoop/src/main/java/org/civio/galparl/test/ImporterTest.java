package org.civio.galparl.test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringUtils;
import org.civio.galparl.utils.RegExp;
import org.junit.Test;

public class ImporterTest {

	@Test
	public void testRemoveSpecialChars() {
		String word = "%NóVo-Emprego";
		word = word.toLowerCase();
		word = word.replaceAll("[^a-zA-Z0-9-%áéíóúñ]", "");
		assertEquals(word, "%nóvo-emprego");
	}
	
	@Test
	public void replaceHyphenAtBeginning() {
		String word = "-absolutamente";
		word = word.toLowerCase();
		word = word.replaceAll("^-", "");
		assertEquals(word, "absolutamente");
	}
	
	@Test
	public void testRemoveBlanks() {
		String word = "       word		";
		word = word.replaceAll("[\\s\\t]", "");
		org.junit.Assert.assertEquals(word, "word");
	}

	@Test
	public void testGetHonors() {
		String str = "O señor OFICIAL MAIOR (Cólera Leirado)";
		str = str.replaceAll("O señor|A señora", "");
		int pos = str.indexOf("(");
		if (pos != -1) {
			str = str.substring(0, str.indexOf("("));
			str = str.trim();
		}
		assertEquals(str, "OFICIAL MAIOR");
	}
	
	@Test
	public void testGetFullname() {
		String str = "O señor OFICIAL MAIOR (Cólera Leirado)";
		String regex = "\\((.*?)\\)$";
		List<String> result = evaluate(regex, str);
		assertFalse(result.isEmpty());
		assertEquals(result.get(0), "Cólera Leirado");
	}
	
	@Test
	public void testGetFullnameWithourHonors() {
		String str = "A señora PORTEIRO GARCÍA";
		String regex = "\\((.*?)\\)$";
		List<String> result = evaluate(regex, str);
		if (result.isEmpty()) {
			str = str.replaceAll("O señor|A señora", "").trim();			
		}
		assertEquals(str, "PORTEIRO GARCÍA");
	}
	
	public static List<String> evaluate(String regex, String line) {
		List<String> result = new ArrayList<String>();
		Pattern pattern = Pattern.compile(regex);

		int count = 1;
		Matcher matcher = pattern.matcher(line);
		while (matcher.find()) {
			result.add(matcher.group(count++));
		}
		return result;
	}

}
