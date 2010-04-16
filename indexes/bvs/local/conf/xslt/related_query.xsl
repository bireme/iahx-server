<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
	<xsl:output method="text" media-type="text/plain; charset=UTF-8" encoding="UTF-8"/> 

	<xsl:template match='/'>
		<xsl:apply-templates select="response/result/doc"/>
	</xsl:template>
  
	<xsl:template match="doc">		
		<xsl:variable name="query">
			<xsl:apply-templates select="*[@name='ti']"/> 

			<xsl:if test="*[@name='mh']">
				OR <xsl:apply-templates select="*[@name='mh']"/>
			</xsl:if>

			<xsl:if test="*[@name='ab'] and not(*[@name='mh'])">
				OR <xsl:apply-templates select="*[@name='ab']"/>
			</xsl:if>
		</xsl:variable>

		<xsl:value-of select="normalize-space($query)"/>
	</xsl:template>

	<xsl:template match="doc/*"/>

	<xsl:template match="doc/*[@name='ti']">
		<xsl:call-template name="globalReplace">
			<xsl:with-param name="outputString" select="."/>
			<xsl:with-param name="target" select="' '"/>
			<xsl:with-param name="replacement" select="' OR '"/>
  		</xsl:call-template>
	</xsl:template>

	<xsl:template match="doc/*[@name='mh']">
		<xsl:text></xsl:text><xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="doc/*[@name='mh']/*">
		<xsl:if test="position() &gt; 1"> OR </xsl:if>
		<xsl:choose>
			<xsl:when test="contains(.,'^s')">"<xsl:value-of select="substring-before(.,'^s')"/>"</xsl:when>
			<xsl:otherwise>"<xsl:value-of select="."/>"</xsl:otherwise>
		</xsl:choose>	
  	</xsl:template>

	<xsl:template match="doc/*[@name='ab']">
		<xsl:text>ab:(</xsl:text><xsl:apply-templates/>)	
	</xsl:template>

	<xsl:template match="doc/*[@name='ab']/*">

		<xsl:variable name="words" select="normalize-space(substring(.,1,200))"/>

		<xsl:call-template name="globalReplace">
			<xsl:with-param name="outputString" select="$words"/>
			<xsl:with-param name="target" select="' '"/>
			<xsl:with-param name="replacement" select="' OR '"/>
  		</xsl:call-template>
	</xsl:template>

	<xsl:template name="globalReplace">
		<xsl:param name="outputString"/>
		<xsl:param name="target"/>
		<xsl:param name="replacement"/>
  
		<xsl:choose>
    		<xsl:when test="contains($outputString,$target)">
				<xsl:value-of select="concat(substring-before($outputString,$target), $replacement)"/>
      			<xsl:call-template name="globalReplace">
	        		<xsl:with-param name="outputString" select="substring-after($outputString,$target)"/>
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="replacement" select="$replacement"/>
				</xsl:call-template>
    		</xsl:when>
    		<xsl:otherwise>
				<xsl:value-of select="$outputString"/>
    		</xsl:otherwise>
  		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
