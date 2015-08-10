<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
<!-- 
Note :
"UTF-8" of 
encoding = can produce  
Code:   0x80004005 (System does not support the specified encoding)
 
Older Microsoft Tools  e.g. MSXSL.EXE
generate encoding="UTF-16" and UTF-16 BOM despite the attribute -->


<xsl:preserve-space elements="*"/>
<!-- 
MSXSL.exe is available at
http://www.microsoft.com/downloads/details.aspx?FamilyID=2fb55371-c94e-4373-b0e9-db4816552e41&displaylang=en
Sample command:
msxsl.exe  config.xml filter.xsl -o defaultconfig.xml  -->

<xsl:output method="xml" normalize-unicode="true" omit-xml-declaration="no" indent="yes"/>
<!-- MSXML.exe produces xml declaration in UTF-16 -->
<xsl:preserve-whitespace select="*"/>
<!--  Start of processing -->
<xsl:template match="/">
<Configuration>
<xsl:apply-templates select="Configuration/ProcessDetection" />
<xsl:apply-templates select="Configuration/WindowDetection" />
<xsl:apply-templates select="Configuration/DialogDetection" />
</Configuration>
</xsl:template>

<xsl:template match="ProcessDetection">
<ProcessDetection>
<xsl:copy-of select="Process[@example]"/>
</ProcessDetection>
</xsl:template>

<xsl:template match="WindowDetection">
<WindowDetection>
<xsl:copy-of select="Window[@example]"/>
</WindowDetection>
</xsl:template>

<xsl:template match="DialogDetection">
<DialogDetection>
<xsl:copy-of select="Pattern[@example]"/>
</DialogDetection>
</xsl:template>

</xsl:stylesheet>