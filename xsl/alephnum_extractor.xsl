<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="marc">
    
<xsl:import href="MARC21slimUtils.xsl"/>
    
<xsl:output method="xml" omit-xml-declaration="no" indent="yes" encoding="utf-8" />

<xsl:template match="/">

<xsl:element name="data">
  
<xsl:for-each select="collection('file:/c:/Users/nh48/documents/github/trenthom/2_marcxml_from_aleph/?select=*.xml')">

 <record>
 <alephnum><xsl:value-of select="//marc:controlfield[@tag='001']"/></alephnum>
 <oclcnum><xsl:value-of select="//marc:datafield[@tag='035']/marc:subfield[@code='a']"/></oclcnum>
 <title><xsl:value-of select="normalize-space(//marc:datafield[@tag='100']|//marc:datafield[@tag='110'])"></xsl:value-of></title>  
 <eadid>trent-<xsl:value-of select="lower-case(translate(//marc:datafield[@tag='100']/marc:subfield [@code='a'] | marc:datafield[@tag='110']/marc:subfield [@code='a'],'1234567890., ',''))"/></eadid>   
 <rlid><xsl:text>rlid_goes_here</xsl:text></rlid>
 </record>
 
</xsl:for-each>
</xsl:element>

</xsl:template>
</xsl:stylesheet>