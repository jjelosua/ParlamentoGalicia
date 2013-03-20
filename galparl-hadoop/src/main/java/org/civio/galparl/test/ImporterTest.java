package org.civio.galparl.test;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

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

}
