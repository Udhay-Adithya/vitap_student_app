use crate::api::vtop::types::PendingPaymentReceipt;
use scraper::{Html, Selector};

/// Parses pending payment details from an HTML string.
///
/// Extracts rows from a specific table in the HTML and returns a vector of `PendingPayment` structs,
/// each populated with serial number, fee preference number, fee heads, end date, amount, fine,
/// total amount, and a fixed payment status of "Unpaid".
///
/// # Examples
///
/// ```
/// let html = r#"
/// <table class="table table-bordered table-responsive table-hover">
///   <tr>
///     <th>S.No</th><th>FPrefNo</th><th>Fees Heads</th><th>End Date</th>
///     <th>Amount</th><th>Fine</th><th>Total Amount</th><th>Status</th>
///   </tr>
///   <tr>
///     <td>1</td><td>12345</td><td>Tuition</td><td>2024-06-30</td>
///     <td>10000</td><td>0</td><td>10000</td><td>Unpaid</td>
///   </tr>
/// </table>
/// "#;
/// let payments = parse_pending_payments(html.to_string());
/// assert_eq!(payments.len(), 1);
/// assert_eq!(payments[0].payment_status, "Unpaid");
/// ```
pub fn parse_pending_payments(html: String) -> Vec<PendingPaymentReceipt> {
    let doc = Html::parse_document(&html);
    let mut results = Vec::new();

    // Find the main table with pending payments
    let table_selector =
        Selector::parse("table.table.table-bordered.table-responsive.table-hover").unwrap();
    if let Some(table) = doc.select(&table_selector).next() {
        let row_selector = Selector::parse("tr").unwrap();
        for var in table.select(&row_selector).take(1) {
            let tds: Vec<_> = var.select(&Selector::parse("td").unwrap()).collect();
            let (mut s_no_index, mut fprefno_index, mut fees_heads_index, mut end_date_index, mut amount_index, mut fine_index, mut advance_amount_index, mut total_amount_index) = (-1, -1, -1, -1, -1, -1, -1, -1);
            for (i, header) in tds.iter().enumerate() {
                let header_text = header.text().collect::<String>().trim().to_lowercase();
                match header_text.as_str() {
                    "sl.no" => s_no_index = i as isize,
                    "fprefno" => fprefno_index = i as isize,
                    "fees heads" => fees_heads_index = i as isize,
                    "end date" => end_date_index = i as isize,
                    "amount" => amount_index = i as isize,
                    "fine" => fine_index = i as isize,
                    "advance amount" => advance_amount_index = i as isize,
                    "total amount" => total_amount_index = i as isize,
                    _ => {}
                }
            }
            for row in table.select(&row_selector).skip(1) {
            let tds: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
            if tds.len() > 0 {
                let s_no = if s_no_index >= 0 { tds[s_no_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let fprefno = if fprefno_index >= 0 { tds[fprefno_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let fees_heads = if fees_heads_index >= 0 { tds[fees_heads_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let end_date = if end_date_index >= 0 { tds[end_date_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let amount = if amount_index >= 0 { tds[amount_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let fine = if fine_index >= 0 { tds[fine_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let advance_amount = if advance_amount_index >= 0 { tds[advance_amount_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                let total_amount = if total_amount_index >= 0 { tds[total_amount_index as usize].text().collect::<String>().trim().to_string() } else { "NA".to_string() };
                // Payment status is always "Unpaid" for pending payments
                results.push(PendingPaymentReceipt {
                    s_no,
                    fprefno,
                    fees_heads,
                    end_date,
                    amount,
                    fine,
                    //advance_amount,
                    total_amount,
                    payment_status: "Unpaid".to_string(),
                });}
            }
        }
        
    }

    results
}

#[cfg(test)]
mod tests { 
    use super::*;

    #[test]
    fn test_parse_pending_payments() {
        let html = r#"
       <!-- <!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
<link rel="stylesheet" type="text/css"	href="assets/css/sweetalert.css" />
<script src="assets/js/sweetalert.min.js"></script>
<head>
</head>
<style>
.m{
font-weight: bold;
color: white;
}


@media (min-width: 1200px)
 {
 bootstrap3-iso .visible-lg {
    display: block !important;
    MARGIN-LEFT: 6PX;
    }
    }
</style>
</head>
<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<section class="content">
		<div class="col-process-flow page-responsive" style=" padding-right: 10px; padding-left: 10px; padding-top:10px" id="main-section" th:fragment="main-section" >
			<div class="box box-solid box box-info">
				<div class="box-header with-border" ><br/>
					<h3 class="box-title  box-info" align="center"> <b>ONLINE  PAYMENT</b></h3>
							/.box-header
							form start							
						<h4 class="text text-danger" th:if="${stopPay!=null}" align="center">Payment Stopped Temporarily, Please try after some times.</h4>
						<h4 class="text text-danger" th:if="${detailMsg!=null}" align="center">Payments Details Not Found</h4>
						<form id="tutPayForm" class="form-horizontal" autocomplete="off" th:if="${stopPay==null && detailMsg==null}">
							<input type="hidden" th:name="${_csrf?.parameterName}" th:value="${_csrf?.token}" />						
							<input type="hidden" name="authorizedID" id="authorizedID" th:value="${session.user.getUserDetails().getUserId()}" />
							
						<div class="box-body">
							<h3 class="text text-danger" th:if="${miscFeePaidStatus!=null}"th:text="${miscFeePaidStatus}"></h3>
								<div th:if="${miscFeePaidStatus==null}">
								<div class="col-12"></div>

									<div class="row-md-6 text-center" style="font-size: 20px; text-align: right; font-weight: Bold; color: red;">
										<strong th:text="${serviceMsg}? ${serviceMsg}:''"> </strong>
										<strong th:text="${error}? ${error}:''"> </strong>
									</div>
									
							
								<div class="visible-lg col-sm-12 col-sm-offset-1 " style="margin-left: -8px;" >
								<div class="col-sm-12 col-sm-offset-1 " style="margin-left: -8px;" >
									<div class="table-responsive" >
										<span class="col-sm-offset-3" style="font-weight: bold;font-size: large; text-align:center; margin-left: 40%;" th:if="${noDues!=null}" th:utext="${noDues}"></span>
											<table class="table table-bordered table-responsive table-hover" th:if="${not #lists.isEmpty(invoiceDetails)} ">
												<tr class="table-primary" align="center">
													<td class="" style="font-weight: bold;">SL.NO</td>
													<td class="" style="font-weight: bold;">FPREFNO</td>
													<td class="" style="font-weight: bold;">FEES HEADS</td>
													<td class="" style="font-weight: bold;">END DATE</td>										
													<td class="" style="font-weight: bold;">AMOUNT </td>
													<td class="" style="font-weight: bold;">FINE </td>
													<td class="" style="font-weight: bold;">ADVANCE AMOUNT </td>
													<td class="" style="font-weight: bold;">TOTAL AMOUNT </td>			
													<td class="" style="font-weight: bold;">ACTION </td>
												</tr>
												<tr th:each="list,iterator:${invoiceDetails}" align="center">
													<td th:text="${iterator.index+1}"></td>
													<td th:text="${list.getInvoiceNumber()}"></td>										
													<td th:text="${list.getPaymentHead()}"></td>				
													<td>
													<span  th:utext="${list.getPaymentCloseDate()}"></span>
													</td>		 
													<td th:text="${list.getInvoiceAmount()}"></td>
													<td th:text="0"></td>
													<td th:text="${list.getAdvancePaidAmount()}"></td>
													<td th:with="result=${list.getCurrencySymbol()}+${list.getPaymentAmount()}">
													<span th:utext="${result}"></span></td>				
													<td> <button style="font-weight: bold;" type="button" class="btn btn-primary" th:onclick="@{'javascript:doPayment(\''+${list.getInvoiceNumber()}+ '\');'}">Pay Now</button></td>
												</tr>			
												
											
											</table>
										</div>
					<span th:text="${msg}"></span>
								<div class="visible-lg col-sm-12" th:if="${not #lists.isEmpty(session.dollarInvoices)}" align="center" >
									<span class="col-sm-offset-3" style="font-weight: bold;font-size: large; text-align:center;" th:if="${dollarInvoices!=null}" th:utext="${noDues}"></span>
							
								<table class="table table-bordered table-responsive table-hover" th:if="${dollarInvoices==null}" >
									<tr align="center" class="table-warning">
										<td style="font-weight: bold;">Sl.No</td>
										<td style="font-weight: bold;">FPRefNo</td>
										<td style="font-weight: bold;">Fees Heads</td>
										<td style="font-weight: bold;">Date</td>									
										<td style="font-weight: bold;">Amount </td>
										<td style="font-weight: bold;">Fine </td>
										<td style="font-weight: bold;">Advance Amount </td>
										<td style="font-weight: bold;">Total Amount </td>
										<td style="font-weight: bold;">Action </td>
									</tr>
									<tr th:each="list,iterator:${session.dollarInvoices}" align="center">
										<td th:text="${iterator.index+1}"></td>
													<td th:text="${list.getInvoiceNumber()}"></td>										
													<td th:text="${list.getPaymentHead()}"></td>				
													<td>
													<span  
															 th:utext="${list.getPaymentOpenDate()}+' to '+'&lt;br /&gt;'+${list.getPaymentCloseDate()}"></span>
													
													</td>		 
													<td th:text="${list.getInvoiceAmount()}"></td>
													<td th:text="0"></td>
													<td th:text="${list.getAdvancePaidAmount()}"></td>
												<td th:with="result=${list.getCurrencySymbol()}+${list.getPaymentAmount()}">
													<span th:utext="${result}"></span></td>
										<td> <button style="font-size: small; font-weight: bold;" type="button" class="btn btn-primary" th:onclick="@{'javascript:doUpload();'}">Upload</button></td>
									</tr>
								</table>
							</div>
							
					------------------------- Alumni Payment ----------------------
					<div class="text-center" style="font-size: 15px; text-align: right; font-weight: Bold; color: red;">
						<strong th:text="${Alumni}? ${Alumni}:''"> </strong>
					</div>
						<div class="col-12" th:if="${not #lists.isEmpty(entryDetails)}">
						<h5 class="text-center"><b>VITAA PAYMENT DETAILS</b></h5>
							<span class="col-sm-offset-3" style="font-weight: bold;font-size: large;" ></span>
								<table class="table table-bordered table-responsive table-hover" >
									<tr align="center" class="table-success">
										<td class="" style="font-weight: bold;">SL.NO</td>
										<td class="" style="font-weight: bold;">FPREFNO</td>
										<td class="" style="font-weight: bold;">APPLICATION NO.</td>
										<td class="" style="font-weight: bold;">OPEN DATE</td>
										<td class="" style="font-weight: bold;">CLOSE DATE</td>
										<td class="" style="font-weight: bold;">PAYMENT HEAD</td>										
										<td class="" style="font-weight: bold;">TOTAL AMOUNT </td>			
										<td class="" style="font-weight: bold;">ACTION </td>
									</tr>
									<tr  th:each="list,iterator:${entryDetails}" align="center">
										<td th:text="${iterator.index+1}"></td>
										<td th:text="${list[0]}"></td>
										<td th:text="${list[1]}"></td>
										<td th:text="${list[2]}"></td>
										<td th:text="${list[3]}"></td>
										<td th:text="${list[4]}"></td>
										<td th:text="${list[5]}"></td>
										<td style="font-size: small;" th:text="${list[6]}"></td>
										<td>
											<button style="font-weight: bold;" type="button" class="btn btn-primary" th:onclick="@{'javascript:doAlumniPayment(\''+${list[0]}+'\',\'' + ${list[1]}+ '\');'}">Pay Now</button>
										</td>
									</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
		</form><br/>
					
			<div  class="alert alert-info " role="alert" style="font-weight: bold;">
             	Note:
					<ul>
                 	  <li><span style="color:maroon; font-weight: bold;">
						Click 'Pay Now' button to make fee adjustment using Wallet (if any amount available in it), view the balance amount to be paid and proceed payment
                     	 </span></li>
              		  </ul>
       		 </div>
			</div>
		</div>
	</div>
<form  id="homePageForm" th:action="@{/content}"></form>
	
						<script th:inline="javascript">
						 				/*<![CDATA[*/				
						 				  /*   var Emessage = '';						 				
						 					if (Emessage!=null)
						 					{
						 					  swal(Emessage,"","error");						 						
						 					}				 				
						 					  var message = '';						 				
						 					if (message!=null)
						 					{					 					  
						 						swal(message,"","error");						 						
						 					}   */
						 				 /*]]>*/
						</script>
						<script th:inline="javascript">
						/*<![CDATA[*/
				
						function doPayment(Invoiceno) {						

						
						var authorizedID = document.getElementById("authorizedID").value;
						var now = new Date();
						var csrfName = /*_csrf*/'';
						var csrfValue = /*d4759e37-445e-46a5-XXXX-6ab059ec8b7f*/'';
						params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString()+"&invoiceNumber="+Invoiceno;
						$.blockUI({
								message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
							});
							$.ajax({
									url : "finance/doOnlinePaymentController",
									type : "POST",
									data : params,
									
									//For Progress Bar
									success : function(response) {
										$.unblockUI();
										$("\#main-section").html(response);
										document.getElementById('homePageForm').submit();
									},
									error : function(jqXHR, textStatus,
											errorMessage) {
										$.unblockUI();
										$("\#upload-file-message")
												.text(
														errorMessage
																+ "Error while Addition");
									}
								});
						$("html, body").animate({
							scrollTop : 0
						}, "slow");
						
					}
						
						function doAlumniPayment(Invoiceno,Applno) {						

							var authorizedID = document.getElementById("authorizedID").value;
							var now = new Date();
							var csrfName = /*_csrf*/'';
							var csrfValue = /*d4759e37-445e-46a5-XXXX-6ab059ec8b7f*/'';
							params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString()+"&invoiceNumber="+Invoiceno+"&Applno="+Applno;
							$.blockUI({
									message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
								});
								$.ajax({
										url : "p2p/alumniPaymentProcess",
										type : "POST",
										data : params,
										async: false,
										//For Progress Bar
										success : function(response) {
											$.unblockUI();
											$("\#main-section").html(response);

										},
										error : function(jqXHR, textStatus,
												errorMessage) {
											$.unblockUI();
											$("\#upload-file-message")
													.text(
															errorMessage
																	+ "Error while Addition");
										}
									});
							$("html, body").animate({
								scrollTop : 0
							}, "slow");
							
							document.getElementById('homePageForm').submit();
						}
					
					
				function doUpload() {						
					var authorizedID = document.getElementById("authorizedID").value;
					var now = new Date();
					var csrfName = /*_csrf*/'';
					var csrfValue = /*d4759e37-445e-46a5-XXXX-6ab059ec8b7f*/'';
					params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString();
					$.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
						$.ajax({
								url : "finance/getOnlineTransfer",
								type : "POST",
								data : params,
								
								//For Progress Bar
								success : function(response) {
									$.unblockUI();
									$("\#main-section").html(response);

								},
								error : function(jqXHR, textStatus,
										errorMessage) {
									$.unblockUI();
									$("\#upload-file-message")
											.text(
													errorMessage
															+ "Error while Addition");
								}
							});
					$("html, body").animate({
						scrollTop : 0
					}, "slow");
				}

				/*]]>*/
				</script>

				</section>
				/.content
			
</body>
</html> -->



<!-- <!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
<link rel="stylesheet" type="text/css"	href="assets/css/sweetalert.css" />
<script src="assets/js/sweetalert.min.js"></script>
<head>
</head>
<style>
.m{
font-weight: bold;
color: white;
}


@media (min-width: 1200px)
 {
 bootstrap3-iso .visible-lg {
    display: block !important;
    MARGIN-LEFT: 6PX;
    }
    }
</style>
</head>
<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<section class="content">
		<div class="col-process-flow page-responsive" style=" padding-right: 10px; padding-left: 10px; padding-top:10px" id="main-section" th:fragment="main-section" >
			<div class="box box-solid box box-info">
				<div class="box-header with-border" ><br/>
					<h3 class="box-title  box-info" align="center"> <b>ONLINE  PAYMENT</b></h3>
							/.box-header
							form start							
						<h4 class="text text-danger" th:if="${stopPay!=null}" align="center">Payment Stopped Temporarily, Please try after some times.</h4>
						<h4 class="text text-danger" th:if="${detailMsg!=null}" align="center">Payments Details Not Found</h4>
						<form id="tutPayForm" class="form-horizontal" autocomplete="off" th:if="${stopPay==null && detailMsg==null}">
							<input type="hidden" th:name="${_csrf?.parameterName}" th:value="${_csrf?.token}" />						
							<input type="hidden" name="authorizedID" id="authorizedID" th:value="${session.user.getUserDetails().getUserId()}" />
							
						<div class="box-body">
							<h3 class="text text-danger" th:if="${miscFeePaidStatus!=null}"th:text="${miscFeePaidStatus}"></h3>
								<div th:if="${miscFeePaidStatus==null}">
								<div class="col-12"></div>

									<div class="row-md-6 text-center" style="font-size: 20px; text-align: right; font-weight: Bold; color: red;">
										<strong th:text="${serviceMsg}? ${serviceMsg}:''"> </strong>
										<strong th:text="${error}? ${error}:''"> </strong>
									</div>
									
							
								<div class="visible-lg col-sm-12 col-sm-offset-1 " style="margin-left: -8px;" >
								<div class="col-sm-12 col-sm-offset-1 " style="margin-left: -8px;" >
									<div class="table-responsive" >
										<span class="col-sm-offset-3" style="font-weight: bold;font-size: large; text-align:center; margin-left: 40%;" th:if="${noDues!=null}" th:utext="${noDues}"></span>
											<table class="table table-bordered table-responsive table-hover" th:if="${not #lists.isEmpty(invoiceDetails)} ">
												<tr class="table-primary" align="center">
													<td class="" style="font-weight: bold;">SL.NO</td>
													<td class="" style="font-weight: bold;">FPREFNO</td>
													<td class="" style="font-weight: bold;">FEES HEADS</td>
													<td class="" style="font-weight: bold;">END DATE</td>										
													<td class="" style="font-weight: bold;">AMOUNT </td>
													<td class="" style="font-weight: bold;">FINE </td>
													<td class="" style="font-weight: bold;">ADVANCE AMOUNT </td>
													<td class="" style="font-weight: bold;">TOTAL AMOUNT </td>			
													<td class="" style="font-weight: bold;">ACTION </td>
												</tr>
												<tr th:each="list,iterator:${invoiceDetails}" align="center">
													<td th:text="${iterator.index+1}"></td>
													<td th:text="${list.getInvoiceNumber()}"></td>										
													<td th:text="${list.getPaymentHead()}"></td>				
													<td>
													<span  th:utext="${list.getPaymentCloseDate()}"></span>
													</td>		 
													<td th:text="${list.getInvoiceAmount()}"></td>
													<td th:text="0"></td>
													<td th:text="${list.getAdvancePaidAmount()}"></td>
													<td th:with="result=${list.getCurrencySymbol()}+${list.getPaymentAmount()}">
													<span th:utext="${result}"></span></td>				
													<td> <button style="font-weight: bold;" type="button" class="btn btn-primary" th:onclick="@{'javascript:doPayment(\''+${list.getInvoiceNumber()}+ '\');'}">Pay Now</button></td>
												</tr>			
												
											
											</table>
										</div>
					<span th:text="${msg}"></span>
								<div class="visible-lg col-sm-12" th:if="${not #lists.isEmpty(session.dollarInvoices)}" align="center" >
									<span class="col-sm-offset-3" style="font-weight: bold;font-size: large; text-align:center;" th:if="${dollarInvoices!=null}" th:utext="${noDues}"></span>
							
								<table class="table table-bordered table-responsive table-hover" th:if="${dollarInvoices==null}" >
									<tr align="center" class="table-warning">
										<td style="font-weight: bold;">Sl.No</td>
										<td style="font-weight: bold;">FPRefNo</td>
										<td style="font-weight: bold;">Fees Heads</td>
										<td style="font-weight: bold;">Date</td>									
										<td style="font-weight: bold;">Amount </td>
										<td style="font-weight: bold;">Fine </td>
										<td style="font-weight: bold;">Advance Amount </td>
										<td style="font-weight: bold;">Total Amount </td>
										<td style="font-weight: bold;">Action </td>
									</tr>
									<tr th:each="list,iterator:${session.dollarInvoices}" align="center">
										<td th:text="${iterator.index+1}"></td>
													<td th:text="${list.getInvoiceNumber()}"></td>										
													<td th:text="${list.getPaymentHead()}"></td>				
													<td>
													<span  
															 th:utext="${list.getPaymentOpenDate()}+' to '+'&lt;br /&gt;'+${list.getPaymentCloseDate()}"></span>
													
													</td>		 
													<td th:text="${list.getInvoiceAmount()}"></td>
													<td th:text="0"></td>
													<td th:text="${list.getAdvancePaidAmount()}"></td>
												<td th:with="result=${list.getCurrencySymbol()}+${list.getPaymentAmount()}">
													<span th:utext="${result}"></span></td>
										<td> <button style="font-size: small; font-weight: bold;" type="button" class="btn btn-primary" th:onclick="@{'javascript:doUpload();'}">Upload</button></td>
									</tr>
								</table>
							</div>
							
					------------------------- Alumni Payment ----------------------
					<div class="text-center" style="font-size: 15px; text-align: right; font-weight: Bold; color: red;">
						<strong th:text="${Alumni}? ${Alumni}:''"> </strong>
					</div>
						<div class="col-12" th:if="${not #lists.isEmpty(entryDetails)}">
						<h5 class="text-center"><b>VITAA PAYMENT DETAILS</b></h5>
							<span class="col-sm-offset-3" style="font-weight: bold;font-size: large;" ></span>
								<table class="table table-bordered table-responsive table-hover" >
									<tr align="center" class="table-success">
										<td class="" style="font-weight: bold;">SL.NO</td>
										<td class="" style="font-weight: bold;">FPREFNO</td>
										<td class="" style="font-weight: bold;">APPLICATION NO.</td>
										<td class="" style="font-weight: bold;">OPEN DATE</td>
										<td class="" style="font-weight: bold;">CLOSE DATE</td>
										<td class="" style="font-weight: bold;">PAYMENT HEAD</td>										
										<td class="" style="font-weight: bold;">TOTAL AMOUNT </td>			
										<td class="" style="font-weight: bold;">ACTION </td>
									</tr>
									<tr  th:each="list,iterator:${entryDetails}" align="center">
										<td th:text="${iterator.index+1}"></td>
										<td th:text="${list[0]}"></td>
										<td th:text="${list[1]}"></td>
										<td th:text="${list[2]}"></td>
										<td th:text="${list[3]}"></td>
										<td th:text="${list[4]}"></td>
										<td th:text="${list[5]}"></td>
										<td style="font-size: small;" th:text="${list[6]}"></td>
										<td>
											<button style="font-weight: bold;" type="button" class="btn btn-primary" th:onclick="@{'javascript:doAlumniPayment(\''+${list[0]}+'\',\'' + ${list[1]}+ '\');'}">Pay Now</button>
										</td>
									</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
		</form><br/>
					
			<div  class="alert alert-info " role="alert" style="font-weight: bold;">
             	Note:
					<ul>
                 	  <li><span style="color:maroon; font-weight: bold;">
						Click 'Pay Now' button to make fee adjustment using Wallet (if any amount available in it), view the balance amount to be paid and proceed payment
                     	 </span></li>
              		  </ul>
       		 </div>
			</div>
		</div>
	</div>
<form  id="homePageForm" th:action="@{/content}"></form>
	
						<script th:inline="javascript">
						 				/*<![CDATA[*/				
						 				  /*   var Emessage = '';						 				
						 					if (Emessage!=null)
						 					{
						 					  swal(Emessage,"","error");						 						
						 					}				 				
						 					  var message = '';						 				
						 					if (message!=null)
						 					{					 					  
						 						swal(message,"","error");						 						
						 					}   */
						 				 /*]]>*/
						</script>
						<script th:inline="javascript">
						/*<![CDATA[*/
				
						function doPayment(Invoiceno) {						

						
						var authorizedID = document.getElementById("authorizedID").value;
						var now = new Date();
						var csrfName = /*_csrf*/'';
						var csrfValue = /*d4759e37-445e-46a5-XXXX-6ab059ec8b7f*/'';
						params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString()+"&invoiceNumber="+Invoiceno;
						$.blockUI({
								message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
							});
							$.ajax({
									url : "finance/doOnlinePaymentController",
									type : "POST",
									data : params,
									
									//For Progress Bar
									success : function(response) {
										$.unblockUI();
										$("\#main-section").html(response);
										document.getElementById('homePageForm').submit();
									},
									error : function(jqXHR, textStatus,
											errorMessage) {
										$.unblockUI();
										$("\#upload-file-message")
												.text(
														errorMessage
																+ "Error while Addition");
									}
								});
						$("html, body").animate({
							scrollTop : 0
						}, "slow");
						
					}
						
						function doAlumniPayment(Invoiceno,Applno) {						

							var authorizedID = document.getElementById("authorizedID").value;
							var now = new Date();
							var csrfName = /*_csrf*/'';
							var csrfValue = /*d4759e37-445e-46a5-XXXX-6ab059ec8b7f*/'';
							params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString()+"&invoiceNumber="+Invoiceno+"&Applno="+Applno;
							$.blockUI({
									message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
								});
								$.ajax({
										url : "p2p/alumniPaymentProcess",
										type : "POST",
										data : params,
										async: false,
										//For Progress Bar
										success : function(response) {
											$.unblockUI();
											$("\#main-section").html(response);

										},
										error : function(jqXHR, textStatus,
												errorMessage) {
											$.unblockUI();
											$("\#upload-file-message")
													.text(
															errorMessage
																	+ "Error while Addition");
										}
									});
							$("html, body").animate({
								scrollTop : 0
							}, "slow");
							
							document.getElementById('homePageForm').submit();
						}
					
					
				function doUpload() {						
					var authorizedID = document.getElementById("authorizedID").value;
					var now = new Date();
					var csrfName = /*_csrf*/'';
					var csrfValue = /*d4759e37-445e-46a5-XXXX-6ab059ec8b7f*/'';
					params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString();
					$.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
						$.ajax({
								url : "finance/getOnlineTransfer",
								type : "POST",
								data : params,
								
								//For Progress Bar
								success : function(response) {
									$.unblockUI();
									$("\#main-section").html(response);

								},
								error : function(jqXHR, textStatus,
										errorMessage) {
									$.unblockUI();
									$("\#upload-file-message")
											.text(
													errorMessage
															+ "Error while Addition");
								}
							});
					$("html, body").animate({
						scrollTop : 0
					}, "slow");
				}

				/*]]>*/
				</script>

				</section>
				/.content
			
</body>
</html> -->




<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css"	href="assets/css/sweetalert.css" />
<script src="assets/js/sweetalert.min.js"></script>
<head>
</head>
<style>
.m{
font-weight: bold;
color: white;
}


@media (min-width: 1200px)
 {
 bootstrap3-iso .visible-lg {
    display: block !important;
    MARGIN-LEFT: 6PX;
    }
    }
</style>
</head>
<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<section class="content">
		<div class="col-process-flow page-responsive" style=" padding-right: 10px; padding-left: 10px; padding-top:10px" id="main-section" >
			<div class="box box-solid box box-info">
				<div class="box-header with-border" ><br/>
					<h3 class="box-title  box-info" align="center"> <b>ONLINE  PAYMENT</b></h3>
							<!-- /.box-header -->
							<!-- form start -->							
						
						
						<form id="tutPayForm" class="form-horizontal" autocomplete="off">
							<input type="hidden" name="_csrf" value="d4759e37-445e-46a5-XXXX-6ab059ec8b7f" />						
							<input type="hidden" name="authorizedID" id="authorizedID" value="23BCEXXXX" />
							
						<div class="box-body">
							
								<div>
							<!-- 	<div class="col-12"></div> -->

									<!-- <div class="row-md-6 text-center" style="font-size: 20px; text-align: right; font-weight: Bold; color: red;">
										<strong th:text="${serviceMsg}? ${serviceMsg}:''"> </strong>
										<strong th:text="${error}? ${error}:''"> </strong>
									</div> -->
									
							
								<!-- <div class="visible-lg col-sm-12 col-sm-offset-1 " style="margin-left: -8px;" > -->
								<div class="col-sm-12 col-sm-offset-1 " style="margin-left: -8px;" >
									<div class="table-responsive" >
										
											<table class="table table-bordered table-responsive table-hover">
												<tr class="table-primary" align="center">
													<td class="" style="font-weight: bold;">SL.NO</td>
													<td class="" style="font-weight: bold;">FPREFNO</td>
													<td class="" style="font-weight: bold;">FEES HEADS</td>
<!-- 													<td class="" style="font-weight: bold;">END DATE</td>										
 -->													<td class="" style="font-weight: bold;">AMOUNT </td>
													<td class="" style="font-weight: bold;">FINE </td>
<!-- 													<td class="" style="font-weight: bold;">ADVANCE AMOUNT </td> -->
													<td class="" style="font-weight: bold;">TOTAL AMOUNT </td>			
													<td class="" style="font-weight: bold;">ACTION </td>
												</tr>
												<tr align="center">
													<td>1</td>
													<td>AM250003XXXX</td>										
													<td>Tuition Fee,Caution Deposit (Refundable)_Tution Fee</td>				
													<!-- <td>
													<span  th:utext="${list.getPaymentCloseDate()}"></span>
													</td>	 -->	 
													<td>70000.0</td>
														<td>0.0</td>
													<!-- <td th:text="0"></td> -->
<!-- 													<td th:text="${list.getAdvancePaidAmount()}"></td>
 -->													<td>
													<span>₹70000.0</span></td>				
													<td> <button style="font-weight: bold;" type="button" class="btn btn-primary" onclick="javascript:doPayment(&#39;AM2500033553&#39;);">Pay Now</button></td>
												</tr>
												<tr align="center">
													<td>2</td>
													<td>AM23000XXXXX</td>										
													<td>Tuition Fee</td>				
													<!-- <td>
													<span  th:utext="${list.getPaymentCloseDate()}"></span>
													</td>	 -->	 
													<td>70000.0</td>
														<td>0.0</td>
													<!-- <td th:text="0"></td> -->
<!-- 													<td th:text="${list.getAdvancePaidAmount()}"></td>
 -->													<td>
													<span>₹70000.0</span></td>				
													<td> <button style="font-weight: bold;" type="button" class="btn btn-primary" onclick="javascript:doPayment(&#39;AM2300085034&#39;);">Pay Now</button></td>
												</tr>
												<tr align="center">
													<td>3</td>
													<td>AM24000XXXXX</td>										
													<td>Tuition Fee,Caution Deposit (Refundable)_Tution Fee</td>				
													<!-- <td>
													<span  th:utext="${list.getPaymentCloseDate()}"></span>
													</td>	 -->	 
													<td>70000.0</td>
														<td>0.0</td>
													<!-- <td th:text="0"></td> -->
<!-- 													<td th:text="${list.getAdvancePaidAmount()}"></td>
 -->													<td>
													<span>₹70000.0</span></td>				
													<td> <button style="font-weight: bold;" type="button" class="btn btn-primary" onclick="javascript:doPayment(&#39;AM2400024864&#39;);">Pay Now</button></td>
												</tr>			
												
											
											</table>
										</div>
					<!-- <span th:text="${msg}"></span> -->
								
							
					<!--------------------------- Alumni Payment ---------------------- -->
					<div class="text-center" style="font-size: 15px; text-align: right; font-weight: Bold; color: red;">
						<!-- <strong th:text="${Alumni}? ${Alumni}:''"> </strong> -->
					</div>
						
					</div>
				</div>
			</div>
		</form><br/>
					
			<div  class="alert alert-info " role="alert" style="font-weight: bold;">
             	Note:
					<ul>
                 	  <li><span style="color:maroon; font-weight: bold;">
						Click 'Pay Now' button to make fee adjustment using Wallet (if any amount available in it), view the balance amount to be paid and proceed payment
                     	 </span></li>
              		  </ul>
       		 </div>
			</div>
		</div>
	</div>
<form  id="homePageForm" action="/vtop/content"></form>
	
						<script>
						 				/*<![CDATA[*/				
						 				  /*   var Emessage = 'null';						 				
						 					if (Emessage!=null)
						 					{
						 					  swal(Emessage,"","error");						 						
						 					}				 				
						 					  var message = 'null';						 				
						 					if (message!=null)
						 					{					 					  
						 						swal(message,"","error");						 						
						 					}   */
						 				 /*]]>*/
						</script>
						<script>
						/*<![CDATA[*/
				
						function doPayment(Invoiceno) {						

						
						var authorizedID = document.getElementById("authorizedID").value;
						var now = new Date();
						var csrfName = "_csrf";
						var csrfValue = "d4759e37-445e-46a5-XXXX-6ab059ec8b7f";
						params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString()+"&invoiceNumber="+Invoiceno;
						$.blockUI({
								message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
							});
							$.ajax({
									url : "finance/doOnlinePaymentController",
									type : "POST",
									data : params,
									
									//For Progress Bar
									success : function(response) {
										$.unblockUI();
										$("\#main-section").html(response);
										document.getElementById('homePageForm').submit();
									},
									error : function(jqXHR, textStatus,
											errorMessage) {
										$.unblockUI();
										$("\#upload-file-message")
												.text(
														errorMessage
																+ "Error while Addition");
									}
								});
						$("html, body").animate({
							scrollTop : 0
						}, "slow");
						
					}
						
						function doAlumniPayment(Invoiceno,Applno) {						

							var authorizedID = document.getElementById("authorizedID").value;
							var now = new Date();
							var csrfName = "_csrf";
							var csrfValue = "d4759e37-445e-46a5-XXXX-6ab059ec8b7f";
							params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString()+"&invoiceNumber="+Invoiceno+"&Applno="+Applno;
							$.blockUI({
									message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
								});
								$.ajax({
										url : "p2p/alumniPaymentProcess",
										type : "POST",
										data : params,
										async: false,
										//For Progress Bar
										success : function(response) {
											$.unblockUI();
											$("\#main-section").html(response);

										},
										error : function(jqXHR, textStatus,
												errorMessage) {
											$.unblockUI();
											$("\#upload-file-message")
													.text(
															errorMessage
																	+ "Error while Addition");
										}
									});
							$("html, body").animate({
								scrollTop : 0
							}, "slow");
							
							document.getElementById('homePageForm').submit();
						}
					
					
				function doUpload() {						
					var authorizedID = document.getElementById("authorizedID").value;
					var now = new Date();
					var csrfName = "_csrf";
					var csrfValue = "d4759e37-445e-46a5-XXXX-6ab059ec8b7f";
					params =csrfName + "=" + csrfValue +"&authorizedID="+authorizedID+"&x="+now.toUTCString();
					$.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
						$.ajax({
								url : "finance/getOnlineTransfer",
								type : "POST",
								data : params,
								
								//For Progress Bar
								success : function(response) {
									$.unblockUI();
									$("\#main-section").html(response);

								},
								error : function(jqXHR, textStatus,
										errorMessage) {
									$.unblockUI();
									$("\#upload-file-message")
											.text(
													errorMessage
															+ "Error while Addition");
								}
							});
					$("html, body").animate({
						scrollTop : 0
					}, "slow");
				}

				/*]]>*/
				</script>

				</section>
				<!-- /.content -->
			
</body>
</html>
        "#;
        let payments = parse_pending_payments(html.to_string());
        assert_eq!(payments.len(), 3);
        assert_eq!(payments[0].fprefno, "AM250003XXXX");
        assert_eq!(payments[1].total_amount, "₹70000.0");
        assert_eq!(payments[2].end_date, "NA");
        println!("{:#?}", payments);
    }
}