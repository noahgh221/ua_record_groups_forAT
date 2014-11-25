<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="marc">

<xsl:import href="MARC21slimUtils.xsl"/>
  
<!--  <xsl:strip-space elements="marc:datafield marc:subfield"/> -->

<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="no" standalone="no" doctype-public="+//ISBN 1-931666-00-8//DTD ead.dtd (Encoded Archival Description (EAD) Version 2002)//EN" doctype-system="./dtds/ead.dtd" media-type="text/xml"/>

<xsl:template match="marc:record">

<!-- Created by Noah Huffman, Duke University -->
<!-- LAST UPDATED by Noah Huffman, 11/24/2014, for use with UA record group to AT project -->
<!-- For use with accompanying stylesheet MARC21slimUtils.xsl, provided with MARCEdit -->
<!-- Converts MARC records for UA record group mss collections to basic EAD finding aids for import into Archivists Toolkit (no <dsc>) -->
  <!-- This XSL was adapated from DukeMARC2EAD-HOMproject.xsl -->

<!-- Call document alephnum2ua_rg_dataset.xml.  This document includes aleph number to UA record group mappings, used to insert <unitid> (e.g. UA01.01.0001) in EAD -->
  <xsl:variable name="alephnum2ua_rg"
    select="document('alephnum2ua_rg_dataset.xml')"/>

<!-- CHANGE NAME VARIABLE AS NEEDED -->
<xsl:variable name="ProcessorName" select="'University Archives Staff'"/>
<xsl:variable name="EncoderName" select="'Noah Huffman'"/>

<!-- Processing and Encoding Dates from MARC 005 - Date record was exported -->
<!--
<xsl:variable name="Year" select="substring(marc:controlfield[@tag='005'],1,4)"/>
<xsl:variable name="MM" select="substring(marc:controlfield[@tag='005'],5,2)"/> 
<xsl:variable name="Month">
<xsl:choose>
      <xsl:when test="$MM = '01'">January</xsl:when>
      <xsl:when test="$MM = '02'">February</xsl:when>
      <xsl:when test="$MM = '03'">March</xsl:when>
      <xsl:when test="$MM = '04'">April</xsl:when>
      <xsl:when test="$MM = '05'">May</xsl:when>
      <xsl:when test="$MM = '06'">June</xsl:when>
      <xsl:when test="$MM = '07'">July</xsl:when>
      <xsl:when test="$MM = '08'">August</xsl:when>
      <xsl:when test="$MM = '09'">September</xsl:when>
      <xsl:when test="$MM = '10'">October</xsl:when>
      <xsl:when test="$MM = '11'">November</xsl:when>
      <xsl:when test="$MM = '12'">December</xsl:when>
</xsl:choose>
</xsl:variable>
-->
  
<!-- Hardcoded Date variable use in place of above, change as needed-->
<xsl:variable name="Year" select="'2014'"/>
<xsl:variable name="Month" select="'November'"/>


<!-- LANGUAGE VARIABLES Add more as needed-->
<xsl:variable name="LangCode" select="substring(marc:controlfield[@tag='008'],36,3)"/>
<xsl:variable name="Language">
<xsl:choose>
      <xsl:when test="$LangCode = 'eng'">English</xsl:when>
      <xsl:when test="$LangCode = 'ger'">German</xsl:when>
      <xsl:when test="$LangCode = 'fre'">French</xsl:when>
      <xsl:when test="$LangCode = 'spa'">Spanish</xsl:when>
      <xsl:when test="$LangCode = 'ita'">Italian</xsl:when>
      <xsl:when test="$LangCode = 'jpn'">Japanese</xsl:when>
      <xsl:when test="$LangCode = 'chi'">Chinese</xsl:when>
	  <xsl:when test="$LangCode = 'lat'">Latin</xsl:when>
	  <xsl:when test="$LangCode = 'dan'">Danish</xsl:when>
      <xsl:when test="$LangCode = 'ice'">Icelandic</xsl:when>
      <xsl:when test="$LangCode = 'gre'">Greek</xsl:when>
      <xsl:when test="$LangCode = 'dut'">Dutch</xsl:when>
      <xsl:otherwise>LANGUAGE?</xsl:otherwise>
</xsl:choose>
</xsl:variable>


<!-- GLOBAL COLLECTION VARIABLES -->
  
<!-- EADID variable for filename, EADID, and URL string -->
<xsl:variable name="EADID">
  <xsl:choose>
    <xsl:when test="marc:datafield[@tag='100']/marc:subfield [@code='a'] | marc:datafield[@tag='110']/marc:subfield [@code='a']">
      <!-- insert ua prefix -->
      <xsl:text>ua</xsl:text>
      <xsl:value-of select='lower-case(translate(marc:datafield[@tag="100"]/marc:subfield [@code="a"] | marc:datafield[@tag="110"]/marc:subfield [@code="a"],"[]&apos;-()1234567890.?!, ",""))'/>
      <xsl:value-of select='lower-case(translate(marc:datafield[@tag="110"]/marc:subfield [@code="b"][1],"[]&apos;-()1234567890.?!,; ",""))'/>
    </xsl:when>
    
    <!-- If no 1xx field, but 245 present, then use title string -->
    <xsl:when test="not(marc:datafield[@tag='100'] | marc:datafield[@tag='110']) and marc:datafield[@tag='245']">
      <xsl:text>ua</xsl:text><xsl:value-of select='lower-case(translate(marc:datafield[@tag="245"]/marc:subfield [@code="a"],"[]&apos;-()1234567890.,?!; ",""))'/>
    </xsl:when>
    
    <!--If no 001 field, then apend zzz and 005 field to sort these at bottom for cleanup -->
    <xsl:when test="not(marc:controlfield[@tag='001'])">
      <text>ua-zzz-</text><xsl:value-of select="marc:controlfield[@tag='005']"/>
    </xsl:when>
    
    <xsl:otherwise>
      <xsl:text>zzz-</xsl:text><xsl:value-of select="marc:controlfield[@tag='001']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
  
 <!-- EADID for filename: removes diacritics from EADID and appends Aleph number to avoid possible 1xx duplicates. Not sure how removing diacritics works. See: http://www.stylusstudio.com/xquerytalk/201106/003547.html -->  
<xsl:variable name="EADID_for_filename">
  <xsl:value-of select="translate(replace(normalize-unicode($EADID,'NFKD'),'[\p{M}]',''), 'đʹ','d')"/>
  <xsl:text>-</xsl:text><xsl:value-of select="marc:controlfield[@tag='001']"/>
</xsl:variable>

<!-- EADID with no diacritics but without Aleph num appended.  Will need to manually edit these files to make this value unique in individual EADs -->
<xsl:variable name="EADID_for_header_and_url">
  <xsl:value-of select="translate(replace(normalize-unicode($EADID,'NFKD'),'[\p{M}]',''), 'đʹ','d')"></xsl:value-of>
</xsl:variable>

<!-- END EADID Variables -->


<!-- Collection Title Variable. Regex replaces trailing comma before $f date-->
<xsl:variable name="CollectionTitle" select="normalize-space(marc:datafield[@tag='245']/marc:subfield [@code='a'])"/>
  
<!-- Collection Normal Date Variables -->

  <xsl:variable name="CollectionNormalStartDateTest" select="substring(marc:controlfield[@tag='008'],8,4)"/>
 <!-- For Start dates, test for various ambiguous dates in MARC fixed fields and correct (e.g. 19uu = 1900) -->
  <xsl:variable name="CollectionNormalStartDate">
    <xsl:choose>
      <xsl:when test="$CollectionNormalStartDateTest = '    '"><xsl:text>uuuu</xsl:text></xsl:when>
      <xsl:when test="$CollectionNormalStartDateTest = 'n.d.'"><xsl:text>uuuu</xsl:text></xsl:when> <!-- WTF?  why is there n.d. in 008? -->
      <xsl:when test="matches($CollectionNormalStartDateTest,'(\d\d\d)u')"><xsl:value-of select="replace($CollectionNormalStartDateTest,'(\d\d\d)u','$10')"/></xsl:when>
      <xsl:when test="matches($CollectionNormalStartDateTest,'(\d\d)uu')"><xsl:value-of select="replace($CollectionNormalStartDateTest,'(\d\d)uu','$100')"/></xsl:when> 
      <xsl:otherwise><xsl:value-of select="$CollectionNormalStartDateTest"/></xsl:otherwise>
    </xsl:choose>   
 </xsl:variable>

<xsl:variable name="CollectionNormalEndDateTest" select="substring(marc:controlfield[@tag='008'],12,4)"/>
 <!-- For End dates, test for various ambiguous dates in MARC fixed fields and correct (e.g. 19uu = 1999) -->
<xsl:variable name="CollectionNormalEndDate">
<xsl:choose>
  <xsl:when test="$CollectionNormalEndDateTest = '    '"><xsl:value-of select="$CollectionNormalStartDate"/></xsl:when> <!-- for single dates, repeats start date as end date -->
  <xsl:when test="$CollectionNormalEndDateTest = 'n.d.'"><xsl:text>uuuu</xsl:text></xsl:when>
  <xsl:when test="$CollectionNormalEndDateTest = 'uuuu'"><xsl:value-of select="$CollectionNormalStartDate"/></xsl:when>
  <xsl:when test="matches($CollectionNormalEndDateTest,'(\d\d\d)u')"><xsl:value-of select="replace($CollectionNormalEndDateTest,'(\d\d\d)u','$19')"/></xsl:when>
  <xsl:when test="matches($CollectionNormalEndDateTest,'(\d\d)uu')"><xsl:value-of select="replace($CollectionNormalEndDateTest,'(\d\d)uu','$199')"/></xsl:when>
  <xsl:otherwise><xsl:value-of select="$CollectionNormalEndDateTest"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--Collection Date Expression Variable -->
<xsl:variable name="CollectionDate" select="marc:datafield[@tag='245']/marc:subfield [@code='f']"/>



<!-- BEGIN EAD DOCUMENT +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:result-document method="xml" href="file:/C:/users/nh48/documents/github/ua_record_groups_forAT/3_eads/{$EADID_for_filename}.xml">

<ead>

<eadheader findaidstatus="Temp_record" countryencoding="iso3166-1" dateencoding="iso8601" langencoding="iso639-2b" repositoryencoding="iso15511">
  <eadid countrycode="US" mainagencycode="US-NcD" publicid="-//David M. Rubenstein Rare Book &amp; Manuscript Library//TEXT (US::NcD::{$CollectionTitle} {$CollectionDate} //EN" url="http://library.duke.edu/rubenstein/findingaids/{$EADID_for_header_and_url}/"><xsl:value-of select="$EADID_for_header_and_url"/></eadid>

<filedesc>
<titlestmt>
  <titleproper>Guide to the <xsl:value-of select="$CollectionTitle"/><xsl:text> </xsl:text><xsl:value-of select="replace($CollectionDate,'\.$','')"/>
  <xsl:if test="marc:datafield[@tag='245']/marc:subfield[@code='b']">
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(replace(marc:datafield[@tag='245']/marc:subfield[@code='b'],'\.$',''))"></xsl:value-of>
  </xsl:if>
  </titleproper>
  <author>Processed by: <xsl:value-of select="$ProcessorName"/>; finding aid derived from MARC record using DukeMARC2EAD_ua_record_groups.xsl</author>
</titlestmt>

<publicationstmt>
  <publisher>David M. Rubenstein Rare Book &amp; Manuscript Library.</publisher>
  <address>
    <addressline>Duke University</addressline>
    <addressline>Durham, NC 27708 U.S.A.</addressline>
    <addressline>919-660-5822</addressline>
    <addressline>special-collections@duke.edu</addressline>
  </address>
  <date normal="{$Year}" encodinganalog="date"><xsl:value-of select="$Year"/></date>
</publicationstmt>

<!-- Insert Aleph Number -->
<notestmt>
  <note>
    <p>Aleph Number: <num type="aleph"><xsl:value-of select="marc:controlfield[@tag='001']"/></num></p>
  </note>
</notestmt>
</filedesc>

<profiledesc>
  <creation>Finding aid derived from MARC record via DukeMARC2EAD_ua_record_groups.xsl <date>November 2014</date></creation>
  <langusage>English</langusage>
  <descrules>Describing Archives: A Content Standard</descrules>
 </profiledesc>
</eadheader>

<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<!-- ARCHDESC -->
<archdesc level="collection">
<did>
     <head>Descriptive Summary</head>
     <repository label="Repository"><corpname>David M. Rubenstein Rare Book &amp; Manuscript Library, Duke University</corpname></repository>
     

  <xsl:variable name="alephnum_string" select="marc:controlfield[@tag='001']"/><!-- local variable for storing Alephnum string in source xml document -->
  <xsl:for-each select="$alephnum2ua_rg/collection/record"> 
  <xsl:if test="alephnum=$alephnum_string">
    <unitid><xsl:value-of select="rlid"/></unitid>
  </xsl:if>
</xsl:for-each>  
     
     
<!-- CREATOR INFO -->
      <xsl:choose>
            <xsl:when test="marc:datafield[@tag='110']">
              <origination label="Creator">
                <corpname encodinganalog="110">
                  <xsl:value-of select="normalize-space(replace(marc:datafield[@tag='110']/marc:subfield[@code='a'],'\.$',''))"/>
                  <xsl:for-each select="marc:datafield[@tag='110']/marc:subfield[@code='b']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                  </xsl:for-each>
                </corpname>
              </origination>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag='100']">
              <origination label="Creator">
                <persname encodinganalog="100">
                  <xsl:value-of select="normalize-space(marc:datafield[@tag='100']/marc:subfield[@code='a'])"/>
                  <xsl:for-each select="marc:datafield[@tag='100']/marc:subfield[@code='q']">
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(.)"/>
				  </xsl:for-each>
          <xsl:for-each select="marc:datafield[@tag='100']/marc:subfield[@code='d']">
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
				  </xsl:for-each>
                </persname>
              </origination>
            </xsl:when>
          </xsl:choose>

		  <!-- TITLE INFO -->

          <unittitle label="Title" encodinganalog="245">
            <xsl:value-of select="replace($CollectionTitle,',$','')"/>
            <xsl:if test="marc:datafield[@tag='245']/marc:subfield [@code='b']">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space(replace(marc:datafield[@tag='245']/marc:subfield [@code='b'],'\.$',''))"/>
            </xsl:if>
          </unittitle>
  
<!-- Date info -->  
       
  
     <xsl:choose>
       <!-- Exclude normal attribute on unitdate when uuuu dates present -->
       <xsl:when test="$CollectionNormalEndDate='uuuu' or contains($CollectionNormalStartDate,'?')"> 
       <unitdate type="inclusive" era="ce" calendar="gregorian">
         <xsl:choose>
           <xsl:when test="matches($CollectionDate,',$')">
             <xsl:value-of select="replace($CollectionDate,',$','')"/>
           </xsl:when>
           <xsl:when test="matches($CollectionDate,'\.$')">
             <xsl:value-of select="replace($CollectionDate,'\.$','')"/>
           </xsl:when>  
           <xsl:otherwise>
             <xsl:value-of select="$CollectionDate"/>
           </xsl:otherwise>
         </xsl:choose>
       </unitdate>
       </xsl:when>
       
       <xsl:otherwise>
         <unitdate normal="{$CollectionNormalStartDate}/{$CollectionNormalEndDate}" type="inclusive" era="ce" calendar="gregorian">
         <xsl:choose>
         <xsl:when test="matches($CollectionDate,',$')">
          <xsl:value-of select="replace($CollectionDate,',$','')"/>
         </xsl:when>
         <xsl:when test="matches($CollectionDate,'\.$')">
           <xsl:value-of select="replace($CollectionDate,'\.$','')"/>
         </xsl:when>  
         <xsl:otherwise>
           <xsl:value-of select="$CollectionDate"/>
         </xsl:otherwise>
          </xsl:choose>
       </unitdate>
       </xsl:otherwise>
     </xsl:choose> 
  
     
  
  
          
<!-- LANGUAGE -->  

  <langmaterial>
  <language langcode="{$LangCode}"/>
</langmaterial>        

<langmaterial label="Language of Materials">Language: <xsl:value-of select="$Language"/></langmaterial>
 
<!-- Language as General note to force AT import - need to move to Language of Materials note using SQL after import -->
<note label="Language of Materials">
  <p>Language: <xsl:value-of select="$Language"/></p>
</note>

<!-- EXTENT -->

<!-- Need to munge extent value to produce one statement with number and type and one with anything in parens 
  Most statements look like this 20 items (0.7 linear ft.)-->
  
<!-- Use 'Extent: ' prefix to prevent creating unnecessary extent types? -->

<xsl:variable name="extent_string">
  <xsl:value-of select="concat(marc:datafield[@tag='300'][1]/marc:subfield[@code='a'], marc:datafield[@tag='300'][1]/marc:subfield[@code='f'] )"/>
</xsl:variable>

<xsl:choose>
  <xsl:when test="contains($extent_string, 'lin') and contains($extent_string, ')')">
  <physdesc>
    <extent><xsl:value-of select="substring-before(substring-after($extent_string, '('), 'lin')"/><xsl:text> linear feet</xsl:text></extent>
  </physdesc>
  </xsl:when>
  
  <xsl:when test="contains($extent_string, 'lin') and not(contains($extent_string, ')'))">
    <physdesc>
      <extent><xsl:value-of select="substring-before($extent_string, 'lin')"/><xsl:text> linear feet</xsl:text></extent>
    </physdesc>
  </xsl:when>
  
<xsl:when test="contains($extent_string, 'item') and not(contains($extent_string, 'lin'))">
  <physdesc>
    <extent><xsl:value-of select="substring-before($extent_string,'item')"/><xsl:text> items</xsl:text></extent>
  </physdesc>
</xsl:when>

  
<xsl:otherwise>
  <physdesc>
    <extent><xsl:value-of select="$extent_string"/></extent>
  </physdesc>
</xsl:otherwise>  
 </xsl:choose> 
  
  
<!-- Old extent code
              <xsl:for-each select="marc:datafield[@tag='300']">
              <physdesc>
                <extent encodinganalog="300"><xsl:text>Extent: </xsl:text><xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="replace(marc:subfield [@code='f'],'\.$','')"/> 
                </extent>
              </physdesc>
              </xsl:for-each>
 --> 
  
  

<!-- LOCATION -->
<physloc label="Location">For current information on the location of these materials, please consult the Library's online catalog.</physloc>

<!-- ABSTRACT -->
  
<!-- concat 545 and 520 into abstract
        <xsl:choose>
          <xsl:when test="marc:datafield[@tag='545']">
              <abstract label="Abstract">
                <xsl:value-of select="marc:datafield[@tag='545']"/>
                <xsl:text> </xsl:text>
                <xsl:for-each select="marc:datafield[@tag='520']">
                  <xsl:value-of select="."/>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </abstract>
          </xsl:when>
          
          <xsl:otherwise>
              <abstract label="Abstract">
                <xsl:for-each select="marc:datafield[@tag='520']">
                  <xsl:value-of select="."/>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </abstract>
            </xsl:otherwise>
        </xsl:choose>
 -->
  
  <!-- Use only 520 as abstract -->
  
 <xsl:if test="marc:datafield[@tag='520']">
  <abstract label="Abstract">
    <xsl:for-each select="marc:datafield[@tag='520']">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </abstract>
</xsl:if>



</did>
        

<!-- ADMINISTRATIVE INFO -->

<descgrp type="admininfo">
          <head>Administrative Information</head>
          
          <accessrestrict encodinganalog="506">
            <head>Access Restrictions</head>
            <xsl:choose>
              <xsl:when test="marc:datafield[@tag='506']">
                <xsl:for-each select="marc:datafield[@tag='506']">
                  <p><xsl:value-of select="normalize-space(.)"/></p>
                </xsl:for-each>
                <p>Researchers must register and agree to copyright and privacy laws before using this collection.</p>                
                <p>All or portions of this collection may be housed off-site in Duke University's Library Service Center. The library may require up to 48 hours to retrieve these materials for research use.</p>                
                <p>Please contact Research Services staff before visiting the University Archives to use this collection.</p>
              </xsl:when>
              
              <xsl:otherwise>
                <p>Collection is open for research.</p>
                <p>Researchers must register and agree to copyright and privacy laws before using this collection.</p>                
                <p>All or portions of this collection may be housed off-site in Duke University's Library Service Center. The library may require up to 48 hours to retrieve these materials for research use.</p>                
                <p>Please contact Research Services staff before visiting the University Archives to use this collection.</p>
              </xsl:otherwise>
            </xsl:choose>
          </accessrestrict>
          
          <xsl:if test="marc:datafield[@tag='530']">
            <altformavail encodinganalog="530">
              <head>Alternate Form of Material</head>
              <xsl:for-each select="marc:datafield[@tag='530']">
              <p><xsl:value-of select="normalize-space(.)"/></p>
              </xsl:for-each>
            </altformavail>
          </xsl:if>
          
          <userestrict encodinganalog="540">
            <head>Use Restrictions</head>
            <p>Copyright for Official University records is held by Duke University; all other copyright is retained by the authors of items in these papers, or their descendants, as stipulated by United States copyright law.</p>
          </userestrict>

          <prefercite encodinganalog="524">
            <head>Preferred Citation</head>
            <p>[Identification of item], in the <xsl:value-of select="replace($CollectionTitle,'letter','Letter')"/><xsl:text> </xsl:text><xsl:value-of select="replace($CollectionDate,'\.$','')"/>
              <xsl:if test="marc:datafield[@tag='245']/marc:subfield[@code='b']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(replace(marc:datafield[@tag='245']/marc:subfield[@code='b'],'\.$',''))"></xsl:value-of>
              </xsl:if>
              <xsl:text>, Duke University Archives, David M. Rubenstein Rare Book &amp; Manuscript Library, Duke University.</xsl:text></p>
          </prefercite>
          
          <xsl:if test="marc:datafield[@tag='541']">
            <acqinfo encodinganalog="541">
              <head>Provenance</head>
              <xsl:for-each select="marc:datafield[@tag='541']">
                <p><xsl:value-of select="normalize-space(replace(translate(.,'.',''), ';', ','))"/></p>
              </xsl:for-each>
            </acqinfo>
          </xsl:if>
          
          <processinfo>
            <head>Processing Information</head>
            <p>Processed by: <xsl:value-of select="$ProcessorName"/></p>
            <p>Finding aid derived from MARC record, <xsl:value-of select="$Month"/><xsl:text> </xsl:text><xsl:value-of select="$Year"/></p>
          </processinfo>
</descgrp>
        

<!-- BIOGRAPHICAL NOTE -->
<xsl:if test="marc:datafield[@tag='545']">
          <bioghist>
            <head>Historical Note</head>
            <xsl:for-each select="marc:datafield[@tag='545']">
            <p><xsl:value-of select="normalize-space(.)"/></p>
            </xsl:for-each>
          </bioghist>
        </xsl:if>
        
<!-- COLLECTION OVERVIEW -->
  <xsl:if test="marc:datafield[@tag='520']">      
  <scopecontent>
          <head>Collection Overview</head>
          <xsl:for-each select="marc:datafield[@tag='520']">
            <p><xsl:value-of select="normalize-space(.)"/></p>
          </xsl:for-each>
        </scopecontent>
  </xsl:if>
  
  <!-- Generic 500 note -->
  <xsl:if test="marc:datafield[@tag='500']">
     <xsl:for-each select="marc:datafield[@tag='500']">
        <note label="General note">
          <p><xsl:value-of select="normalize-space(.)"/></p>
        </note>
      </xsl:for-each>
   </xsl:if>
  
<!-- ARRANGEMENT -->
        <xsl:if test="marc:datafield[@tag='351']">
          <arrangement encodinganalog="351">
            <xsl:for-each select="marc:datafield[@tag='351']/marc:subfield">
              <p><xsl:value-of select="normalize-space(.)"/></p>
            </xsl:for-each>
          </arrangement>
        </xsl:if>
        
        
<!-- ONLINE CATALOG HEADINGS -->


  <xsl:if test="marc:datafield[@tag='600'] | marc:datafield[@tag='610'] | marc:datafield[@tag='650'] | marc:datafield[@tag='655'] | marc:datafield[@tag='611'] | marc:datafield[@tag='651'] | marc:datafield[@tag='700'] | marc:datafield[@tag='710']">
  <controlaccess>
          <!-- TOPICAL SUBJECTS -->
          
          <!-- MESH Topics -->
          <xsl:if test="marc:datafield[@tag='650'][@ind2='2']">
            <xsl:for-each select="marc:datafield[@tag='650'][@ind2='2']">
                <subject source="mesh" encodinganalog="650">
                    <xsl:value-of select="normalize-space(replace(marc:subfield[@code='a'],'\.$',''))"/>
                    <xsl:for-each select="marc:subfield[@code='x'] | marc:subfield[@code='v'] | marc:subfield[@code='y'] | marc:subfield[@code='z']">
                      <xsl:text> -- </xsl:text>
                      <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                    </xsl:for-each>
                  </subject>
              </xsl:for-each>
            </xsl:if>
          
          <!-- LCSH Topics -->
          <xsl:if test="marc:datafield[@tag='650'][@ind2='0']">
          <xsl:for-each select="marc:datafield[@tag='650'][@ind2='0']">
            <subject source="lcsh" encodinganalog="650">
              <xsl:value-of select="normalize-space(replace(marc:subfield[@code='a'],'\.$',''))"/>
              <xsl:for-each select="marc:subfield[@code='x'] | marc:subfield[@code='v'] | marc:subfield[@code='y'] | marc:subfield[@code='z']">
                <xsl:text> -- </xsl:text>
                <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
              </xsl:for-each>
            </subject>
          </xsl:for-each>
          </xsl:if>
            
          <xsl:if test="marc:datafield[@tag='600'][@ind1='1'] | marc:datafield[@tag='700'][@ind1='1']">
              <xsl:for-each select="marc:datafield[@tag='600'][@ind1='1'] | marc:datafield[@tag='700'][@ind1='1']">
                <xsl:sort select="marc:subfield[@code='a']"/>
                <xsl:choose>
                  <xsl:when test="@tag='600'">
                   
                      <persname source="lcsh" encodinganalog="600">
                        
                        
                        <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
                        <xsl:if test ="marc:subfield[@code='a'] and marc:subfield[@code='d']">
                          <xsl:text> </xsl:text>
                        </xsl:if>
                        
                        <xsl:if test="marc:subfield[@code='q']">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='q'])"/>
                        <xsl:text> </xsl:text>
                        </xsl:if>
                        
                        <xsl:if test="marc:subfield[@code='d']">
                        <xsl:value-of select="normalize-space(replace(marc:subfield[@code='d'],'\.$',''))"/>
                        </xsl:if>
                        
                        <xsl:if test="marc:subfield[@code='c']">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='c'])"/>
                        <xsl:text> </xsl:text>
                        </xsl:if>
                        
                        <xsl:if test="marc:subfield[@code='e']">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='e'])"/>
                        </xsl:if>
                        
                        <xsl:for-each select="marc:subfield[@code='x'] | marc:subfield[@code='v'] | marc:subfield[@code='y'] | marc:subfield[@code='z']">
                          <xsl:text> -- </xsl:text>
                          <xsl:value-of select="normalize-space(replace(.,',$',''))"/>
                        </xsl:for-each>                      
                    </persname>
            
                  </xsl:when>
                  <xsl:otherwise>
                    
                      <persname source="lcsh" encodinganalog="700">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(marc:subfield[@code='q'])"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(replace(marc:subfield[@code='d'],'\.$',''))"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(marc:subfield[@code='e'])"/>
                      </persname>
                    
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:if>
         
    
    
         
          <!--FOR FAMILY NAMES -->
            <xsl:if test="marc:datafield[@tag='600'][@ind1='3'] | marc:datafield[@tag='700'][@ind1='3']">
              <xsl:for-each select="marc:datafield[@tag='600'][@ind1='3'] | marc:datafield[@tag='700'][@ind1='3']">
                <xsl:sort select="marc:subfield[@code='a']"/>
                <xsl:choose>
                  <xsl:when test="@tag='600'">
                    
                      <famname source="lcsh" encodinganalog="600">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(marc:subfield[@code='q'])"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(replace(marc:subfield[@code='d'],'\.$',''))"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(marc:subfield[@code='e'])"/>
                        <xsl:for-each select="marc:subfield[@code='x'] | marc:subfield[@code='v'] | marc:subfield[@code='y'] | marc:subfield[@code='z']">
                          <xsl:text> -- </xsl:text>
                          <xsl:value-of select="normalize-space(.)"/>
                        </xsl:for-each>
                      </famname>
                    
                  </xsl:when>
                  <xsl:otherwise>
                    
                      <famname source="lcsh" encodinganalog="700">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(marc:subfield[@code='q'])"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(replace(marc:subfield[@code='d'],'\.$',''))"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(marc:subfield[@code='e'])"/>
                      </famname>
                    
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='610'] | marc:datafield[@tag='710']">
              <xsl:for-each select="marc:datafield[@tag='610'] | marc:datafield[@tag='710']">
                <xsl:sort select="marc:subfield[@code='a']"/>
                <xsl:choose>
                  <xsl:when test="@tag='610'">
                    
                      <corpname source="lcsh" encodinganalog="610">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
                        <xsl:for-each select="marc:subfield[@code='b']">
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                        </xsl:for-each>
                        <xsl:for-each select="marc:subfield[@code='x'] | marc:subfield[@code='v'] | marc:subfield[@code='y'] | marc:subfield[@code='z']">
                          <xsl:text> -- </xsl:text>
                          <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                        </xsl:for-each>
                      </corpname>
                    
                  </xsl:when>
                  <xsl:otherwise>
                    
                      <corpname source="lcsh" encodinganalog="710">
                        <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
                        <xsl:for-each select="marc:subfield[@code='b']">
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="normalize-space(.)"/>
                        </xsl:for-each>
                      </corpname>
                    
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='651']">
              <xsl:for-each select="marc:datafield[@tag='651']">
                <xsl:sort select="marc:subfield[@code='a']"/>
                
                  <geogname source="lcsh" encodinganalog="651">
                    <xsl:value-of select="normalize-space(replace(marc:subfield[@code='a'],'\.$',''))"/>
                    <xsl:for-each select="marc:subfield[@code='b']">
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                    <xsl:for-each select="marc:subfield[@code='x'] | marc:subfield[@code='v'] | marc:subfield[@code='y'] | marc:subfield[@code='z']">
                      <xsl:text> -- </xsl:text>
                      <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                    </xsl:for-each>
                  </geogname>
                
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='655'][@ind2='7']">
              <xsl:for-each select="marc:datafield[@tag='655'][@ind2='7']/marc:subfield[@code='a']">
                <xsl:sort select="marc:subfield[@code='a']"/>
                
                  <genreform source="aat" encodinganalog="655">
                    <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                  </genreform>
                
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='655'][@ind2='0']">
              <xsl:for-each select="marc:datafield[@tag='655'][@ind2='0']/marc:subfield[@code='a']">
                <xsl:sort select="marc:subfield[@code='a']"/>
               
                  <genreform source="lcsh" encodinganalog="655">
                    <xsl:value-of select="normalize-space(replace(.,'\.$',''))"/>
                  </genreform>
                
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='656']">
              <xsl:for-each select="marc:datafield[@tag='656']/marc:subfield[@code='a']">
                
                  <occupation encodinganalog="656">
                    <xsl:value-of select="normalize-space(.)"/>
                  </occupation>
                
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='657']">
              <xsl:for-each select="marc:datafield[@tag='657']/marc:subfield[@code='a']">
               
                  <function encodinganalog="657">
                    <xsl:value-of select="normalize-space(.)"/>
                  </function>
                
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag='630']">
              <xsl:for-each select="marc:datafield[@tag='630']">
                
                  <title encodinganalog="630">
                    <xsl:value-of select="normalize-space(.)"/>
                  </title>
                
              </xsl:for-each>
            </xsl:if>
          
        </controlaccess>
  </xsl:if>
    
    
    <!-- RELATED MATERIAL -->
        
    <xsl:if test="marc:datafield[@tag='544']">
          <relatedmaterial encodinganalog="544">
            <head>Related Material</head>
            <xsl:for-each select="marc:datafield[@tag='544']">
            <p><xsl:value-of select="normalize-space(marc:subfield[@code='d'])"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
            </p>
              </xsl:for-each>
          </relatedmaterial>
        </xsl:if>
        
     </archdesc>
    </ead>

</xsl:result-document>

</xsl:template>
</xsl:stylesheet>