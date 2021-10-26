using FluentAssertions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SeleniumParser.Driver;

namespace SeleniumParser.Tests.Driver
{
	[TestClass]
	public class StringExtensionsTest
	{

		[TestMethod]
		public void SeStringsForemIguaisDeveRetornarVerdadeiro()
		{
			"TESTES DE INTEGRAÇÃO".IsEquals("Testes de Integração")
				.Should()
				.BeTrue();

			"TESTES DE INTEGRAÇÃO".IsEquals("Testes de Integracao")
				.Should()
				.BeFalse();
		}

		[TestMethod]
		public void SeConverterTextoParaNumeroDeveGerarResultadoEsperado()
		{
			"123".ToInt()
				.Should()
				.Be(123);

			"a123".ToInt()
				.Should()
				.Be(0);
		}

		[TestMethod]
		public void SeUmTextoConterOutroDeveRetornarValorEsperado()
		{
			"TESTES DE INTEGRAÇÃO".ContainsText("Integração")
				.Should()
				.BeTrue();

			"TESTES DE INTEGRAÇÕES".ContainsText("Integracao")
				.Should()
				.BeFalse();
		}

		[TestMethod]
		public void SeUmTextoIniciarComOutroDeveRetornarValorEsperado()
		{
			string text = null;

			text.StartsWithText("testes de")
				.Should()
				.BeFalse();

			"TESTES DE INTEGRAÇÃO".StartsWithText("testes de")
				.Should()
				.BeTrue();

			"TESTES DE INTEGRAÇÕES".StartsWithText("teste de")
				.Should()
				.BeFalse();

			"TESTES DE INTEGRAÇÕES".StartsWithText(null)
				.Should()
				.BeFalse();
		}

	}
}
