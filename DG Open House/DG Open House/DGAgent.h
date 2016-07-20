//
//  DGAgent.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface DGAgent : JSONModel

@property (nonatomic) NSString *agentID;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) NSString *liborNumber;
@property (nonatomic) NSString *liborNumber2;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *officePhone;
@property (nonatomic) NSString *photoURL;
@property (nonatomic) NSString *officeAddress;

@end

/*

 cn = "Krystina Cuesta";
 createTime = "0000-00-00 00:00:00";
 displayname = "Krystina Cuesta";
 dn = c;
 givenname = Krystina;
 id = 539967;
 "login_token" = bbeb70dd0fed9d997351a51f;
 mail = "krystinacuesta@danielgale.com";
 mailalternateaddress = "christinacuesta@danielgale.com";
 mailnickname = 0;
 "token_expiration" = "2016-03-11";
 updateTime = "2016-02-11 02:45:05";
 userprincipalname = "krystinacuesta@danielgale.com";
 "web_address1" = "42-30 Douglaston Pkwy., Apt. 4N";
 "web_address2" = "";
 "web_agentappurl" = "http://app.danielgale.com/DGSIR4VF";
 "web_agentbio" = "Krystina Cuesta, Real Estate Salesperson, has been a dynamic presence with Daniel Gale Sotheby\U2019s International Realty since 2008. Having worked in the Syosset/Woodbury, Manhasset and Queens offices, Krystina has extensive knowledge of neighborhoods spanning from Long Island through New York City.
 \n
 \nKrystina has created an effective team in the Long Island and Queens real estate markets which provides both buyers and sellers with multi-tiered services; clients benefit from the knowledge and experience of the entire team. When working with Krystina Cuesta as your real estate representative, you also gain her team of talented associates who are fluent in English, Greek and Spanish.
 \n
 \nHailing from a Real Estate family, Krystina gained early experience with development, property management and in-depth valuation of both commercial and multi-unit residential properties. Much of Krystina\U2019s time is dedicated to selling properties in a variety of price ranges and enjoys working with a variety of U.S. and international clients.
 \n
 \nKrystina is a member of National Association of Realtors, New York State Association of Realtors and Long Island Board of Realtors. She holds a B.S. in Finance from Fordham University.
 \n
 \nIn addition to her career in Real Estate, Krystina is committed to supporting a number of charitable institutions including New York Cares and City Harvest. Active in her neighborhood, Krystina is also involved in her local Community Board. She enjoys boating, cooking and exploring the rich arts and cultural resources that New York has to offer.";
 "web_agentcircle" = "";
 "web_agentphotourl" = "images/agentphotos/CuestaK.jpg";
 "web_businessphone" = "";
 "web_businessphoneext" = "";
 "web_city" = Douglaston;
 "web_commissionsplit" = "55.000";
 "web_crestid" = 4012292;
 "web_dateofbirth" = "1987-03-12";
 "web_display" = 1;
 "web_display_feature" = 1;
 "web_emailaddress" = "krystinacuesta@danielgale.com";
 "web_emailaddresspassword" = Password1;
 "web_emailpass" = Password1;
 "web_experiencedagent" = 0;
 "web_facebookurl" = "";
 "web_fax" = "";
 "web_firstname" = Krystina;
 "web_gender" = FEMALE;
 "web_googleurl" = "";
 "web_homefax" = "";
 "web_homephone" = 5164581121;
 "web_inactivedate" = "2016-01-16";
 "web_jobtittle" = "Real Estate Salesperson";
 "web_lastname" = Cuesta;
 "web_libornumber" = 155614;
 "web_libornumber2" = "";
 "web_licenseexpirationdate" = "0000-00-00";
 "web_licensenumber" = 10401203274;
 "web_licensetype" = "Sales Person";
 "web_linkedinurl" = "";
 "web_memberno" = 155614;
 "web_microsofturl" = "";
 "web_middlename" = "";
 "web_mobilephone" = 5164581121;
 "web_newagenttrainingcompleted" = 0;
 "web_office" = UA;
 "web_office2" = "";
 "web_password" = d41d8cd98f00b204e9800998ecf8427e;
 "web_referraldate" = "0000-00-00";
 "web_rezorapassword" = "";
 "web_role" = Agent;
 "web_signature" = "";
 "web_smsemail" = "";
 "web_startdate" = "2012-06-21";
 "web_state" = NY;
 "web_status" = active;
 "web_subdomain" = "";
 "web_textcode" = DGSIR4VF;
 "web_total_properties" = 8;
 "web_twitterurl" = "";
 "web_usertype" = "Field Agent";
 "web_usesignature" = 0;
 "web_website" = "";
 "web_xpressdocspassword" = "";
 "web_zipcode" = 11363;

*/