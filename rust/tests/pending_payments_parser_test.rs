use lib_vtop::api::vtop::parser::pending_payments_parser::parse_pending_payments;

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
