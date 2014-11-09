# encoding: utf-8

template_path "./templates"

define Config: "demo" do
  # Get time for execution date
  t = Time.now + (60*60*24*5)
  # Hash for instruction variables
  @instruction = { 
    batch: "true",
    execdate: t.strftime("%F"),
  }
end

define Template: "interchange_header" do
%q(<?xml version="1.0" encoding="UTF-8"?>
<!-- Mit XMLSpy v2008 rel. 2 sp2 (http://www.altova.com) von benutzerservice benutzerservice (SIZ GmbH) bearbeitet -->
<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.003.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:iso:std:iso:20022:tech:xsd:pain.001.003.03 http://www.ebics.de/fileadmin/unsecured/anlage3/anlage3_pain001/pain_schema/pain.001.003.03.xsd">
	<CstmrCdtTrfInitn>
)
end

define Template: "interchange_footer" do
%q(	</CstmrCdtTrfInitn>
</Document>
)
end

define Template: "instruction_header" do
%q(		<PmtInf>
			<PmtInfId><%= Time.now.strftime("PMTID%Y%m%dT%H%M%SN%9N") %></PmtInfId>
			<PmtMtd>TRF</PmtMtd>
			<BtchBookg><%= @instruction[:batch] %></BtchBookg>
			<NbOfTxs>2</NbOfTxs>
			<CtrlSum>6655.86</CtrlSum>
			<PmtTpInf>
				<SvcLvl>
					<Cd>URGP</Cd>
				</SvcLvl>
			</PmtTpInf>
			<ReqdExctnDt><%= @instruction[:execdate] %></ReqdExctnDt>
			<Dbtr>
				<Nm>Debtor Name</Nm>
			</Dbtr>
			<DbtrAcct>
				<Id>
					<IBAN>DE87200500001234567890</IBAN>
				</Id>
			</DbtrAcct>
			<DbtrAgt>
				<FinInstnId>
					<BIC>BANKDEFFXXX</BIC>
				</FinInstnId>
			</DbtrAgt>
			<ChrgBr>SLEV</ChrgBr>
)
end

define Template: "instruction_footer" do
%q(		</PmtInf>
)
end

define Template: "transaction" do
%q(			<CdtTrfTxInf>
				<PmtId>
					<EndToEndId><%= Time.now.strftime("E2E%Y%m%dT%H%M%SN%9N") %></EndToEndId>
				</PmtId>
				<Amt>
					<InstdAmt Ccy="EUR">6543.14</InstdAmt>
				</Amt>
				<CdtrAgt>
					<FinInstnId>
						<BIC>SPUEDE2UXXX</BIC>
					</FinInstnId>
				</CdtrAgt>
				<Cdtr>
					<Nm>Creditor Name</Nm>
				</Cdtr>
				<CdtrAcct>
					<Id>
						<IBAN>DE21500500009876543210</IBAN>
					</Id>
				</CdtrAcct>
				<RmtInf>
					<Ustrd>Unstructured Remittance Information</Ustrd>
				</RmtInf>
			</CdtTrfTxInf>
)
end

define Task: :demo do
  config :demo
  template :interchange_header
  template :groupheader
  template :instruction_header
  template :transaction
  template :instruction_footer
  template :interchange_footer
end
