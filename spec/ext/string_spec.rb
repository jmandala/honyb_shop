require_relative '../spec_helper'

describe String do
  it "should string dashes" do
    'string-with-dashes'.no_dashes.should == 'stringwithdashes'
  end

  it "should allow left justified padding formatting" do
    "abc".ljust_trim(10).should == "abc       "
    "abc".ljust_trim(10, "-").should == "abc-------"
  end


  #it "should wrap every x characters" do
  #  orig = "02000011697978     INGRAM       110810RUYFU110809180859.FBO F030000000     1    1100002             R543255800            20N273016979780110810110810110810     2100003R543255800            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100004R543255800            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100005R543255800            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100006R543255800            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100007R543255800            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100008R543255800             AT 1-800-234-6737.                                4000009R543255800            2                     9780373200009       00100100C4100010R543255800            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200011R543255800            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300012R543255800            HQPB                030900019350000000010000000    4400013R543255800                                00004.99EN00003.240000001      4500014R543255800            2                                                  4000015R543255800            5                     978037352805        00100005C4100016R543255800            000         0000 0000 0000 0000 0000 0000 0000     4100017R543255800            000 000000  0000 0000 0000 0000 0000 0000 0000     4200018R543255800                                                               4300019R543255800                                    00022000000000000000000    4400020R543255800                                00000.00EN00000.000000001      4500021R543255800            5                                                  5900022R543255800            0002000000000020000000001000000000400000000000000011100023             R554266337            20N273016979780110810110810110810     2100024R554266337            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100025R554266337            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100026R554266337            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100027R554266337            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100028R554266337            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100029R554266337             AT 1-800-234-6737.                                4000030R554266337            3                     9780373200009       00100100C4100031R554266337            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200032R554266337            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300033R554266337            HQPB                030900043350000000010000000    4400034R554266337                                00004.99EN00003.240000001      4500035R554266337            3                                                  4000036R554266337            6                     978037352805        00100005C4100037R554266337            000         0000 0000 0000 0000 0000 0000 0000     4100038R554266337            000 000000  0000 0000 0000 0000 0000 0000 0000     4200039R554266337                                                               4300040R554266337                                    00046000000000000000000    4400041R554266337                                00000.00EN00000.000000001      4500042R554266337            6                                                  5900043R554266337            0002000000000020000000001000000000400000000000000019100044000000000000400002000000000200001000020001200000000260000200001          "
  #  puts orig.scan(/.{80}/).join("\r\n")
  #end
end
