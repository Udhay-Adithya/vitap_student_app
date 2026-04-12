use lib_vtop::api::vtop::parser::digital_assignment_parser::
    {parse_all_assignments, parse_per_course_dassignments,
     parse_process_upload_assignment_response, parse_upload_assignment_response};
    #[test]
    fn test_parse_all_assignments() {
        //digital assignments page with no data found response
        let html = r#"<!DOCTYPE html>
<!--
  Author: Prabakaran Ramu
  Date  : 23/06/2018
  -->
<html>
  <!--<head th:include="layouts/header :: style_sheets">-->
  <head>
    <link rel="stylesheet" href="assets/css/sweetalert.css" />
    <script type="text/javascript" src="assets/js/sweetalert.min.js" charset="utf-8"></script>
  </head>
  <body class="hold-transition skin-blue-light sidebar-mini fixed">
    <div id="main-section">
      <!-- Main content -->
      <section class="content">
        <div class="col-sm-12">
          <div class="box box-info">
            <div class="box-header with-border">
              <h3 class="box-title">Assignment Upload</h3>
            </div>
            <div class="box-body">
              <form role="form" id="digitalAssignment" name="digitalAssignment"
                method="post" autocomplete="off">
                <input type="hidden" name="authorizedID" id="authorizedID"
                  value="2XBCEXXXX" />
                <!-- th:object="${examSchedule}"> -->
                <div class="col-md-16"
                  style="margin-top: 20px; margin-left: 1px;">
                  <div>
                    <div class="col-md-12">
                      <div class="col-md-3"></div>
                      <div class="col-md-6">
                        <br />
                        <div>
                          <label for="acadYear" class="col-sm-4 control-label">Select
                          Semester</label>
                          <div class="col-md-8">
                            <select class="form-control" name="semesterSubId"
                              id="semesterSubId" required="required"
                              onchange="dAOnChange();">
                              <option value="" selected="selected">-- Choose
                                Semester --
                              </option>
                              <option value="AP2025264"
                                selected="selected">Winter Semester 2025-26</option>
                              <option value="AP2025263">Fall Semester 2025-26 Freshers</option>
                              <option value="AMR2017181">FALL SEM (2017-18)</option>
                            </select>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-md-12"
                      style="align-content: center; text-align: center;">
                      <br /> <span
                        style="color: red; font-size: 20px;"> No data found</span>
                    </div>
                    <input type="hidden" id="success" value="" /> <input
                      type="hidden" id="jsonBom" value="" />
                    <script>
                      /*<![CDATA[*/
                      
                      var message = document
                      		.getElementById("jsonBom").value;
                      var success = document
                      		.getElementById("success").value;
                      
                      if (message != "") {
                      	swal(message, "", "error");
                      }
                      
                      if (success != "") {
                      	swal(success, "", "success");
                      }
                      //}				 				
                      
                      /*]]>*/
                    </script>
                  </div>
                </div>
                <script>
                  $(document).ready(function() {
                  	$('[data-toggle="tooltip"]').tooltip();
                  });
                </script>
              </form>
            </div>
          </div>
        </div>
      </section>
      <noscript>
        <h2 class="text-red">Enable JavaScript to Access VTOP</h2>
      </noscript>
      <script type="text/javascript">
        /*<![CDATA[*/
        
        function myFunction(classId) {
        	
        	var csrfName = "_csrf";
                  var csrfValue = "da8eb9d2-55a6-4b09-9d6a-43be87XXXXXX";
        
        	$
        			.blockUI({
        
        				message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
        			});
        
        	var authorizedID = document.getElementById("authorizedID").value;
        	var now = new Date();
        	params = "authorizedID=" + authorizedID + "&x="
        			+ now.toUTCString() + "&classId=" + classId+"&"+csrfName+"="+csrfValue;
        
        	$.ajax({
        		url : "examinations/processDigitalAssignment",
        		type : "POST",
        		data : params,
        
        		success : function(response) {
        			$.unblockUI();
        
        			$("/#main-section").html(response);
        
        		}
        
        	});
        }
        
        function dAOnChange() {
        	var myform = document.getElementById("digitalAssignment");
        	var fd = new FormData(myform);
        	var csrfName = "_csrf";
                  var csrfValue = "da8eb9d2-55a6-4b09-9d6a-43be87XXXXXX";
                  fd.append(csrfName,csrfValue);
        
        	$
        			.blockUI({
        
        				message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
        			});
        	$.ajax({
        		url : "examinations/doDigitalAssignment",
        		type : "POST",
        		data : fd,
        		cache : false,
        		processData : false,
        		contentType : false,
        		success : function(response) {
        			$.unblockUI();
        			$("/#main-section").html(response);
        
        		}
        
        	});
        }
        
        /*]]>*/
      </script>
    </div>
  </body>
</html>"#;
        let result = parse_all_assignments(html.to_string());
        assert_eq!(result.is_empty(), true);
    }

    #[test]
    fn test_parse_per_course_dassignments() {
        //digital assignments per course with no assignments uploaded
        let html = r#"<!DOCTYPE html>
<!--
  Author: Prabakaran Ramu
  Date  : 23/06/2018
  Updated author : Poornima V -- 10/01/2023
-->
<html>
<!--<head th:include="layouts/header :: style_sheets">-->
<head>
<link rel="stylesheet" href="assets/css/sweetalert.css" />
<script type="text/javascript" src="assets/js/sweetalert.min.js"
	charset="utf-8"></script>
</head>

<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<div id="main-section">
		<!-- Main content -->
		<section class="content">
			<div class="col-sm-12">
				<div class="box box-info">

					<div class="box-header with-border">
						<h3 class="box-title">Assignment Upload</h3>
					</div>
					<div class="box-body">

						<form role="form" id="daUpload" name="daUpload" method="post"
							autocomplete="off">
							<input type="hidden" name="authorizedID" id="authorizedID"
								value="2XBCEXXXXX" />
							<!-- th:object="${examSchedule}"> -->
							<div class="col-md-16"
								style="margin-top: 20px; margin-left: 1px;">
								<div>

									<div align="center">
										<span
											style="color: green; font-size: 20px; font-weight: bold;"></span> <span
											style="color: red; font-size: 20px; font-weight: bold;"></span></div>

									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable" style="align: center;">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Semester</td>
													<td style="width: 12%;">Course Code</td>
													<td style="width: 30%;">Course Title</td>
													<td style="width: 12%;">Course Type</td>
													<td style="width: 10%;">Class Number</td>
												</tr>
												<tr class="fixedContent tableContent">
													<td style="width: 20%;">Winter Semester 2025-26</td>
													<td style="width: 10%;">CSE3015</td>
													<td style="width: 30%;">Natural Language Processing</td>
													<td style="width: 10%;">ETH</td>
													<td style="width: 10%;">AP2025264000667</td>
												</tr>
											</tbody>
										</table>
									</div>


									<br /> 
									
								<div class="col-md-10">
									<p style="color: red;">
										Notes:  <br /> 
										1. File size (Max. upto 4MB) <br /> 
										2. File type should be pdf,xls,xlsx,doc,docx <br /> 
									</p>
								</div>
									
									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td rowspan="2" style="width: 5%;">Sl.No.</td>
													<td rowspan="2" style="width: 20%;">Title</td>
													<td rowspan="2" style="width: 5%;">Max. Mark</td>
													<td rowspan="2" style="width: 5%;">Weightage %</td>
													<td rowspan="2" style="width: 10%;">Due Date</td>
													<td rowspan="2" style="width: 5%;">QP</td>
													<td colspan="3" style="width: 50%;">Document Details</td>
												</tr>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Last Updated On</td>
													<td style="width: 20%;">Upload/Edit</td>
													<td style="width: 20%;">Download</td>
												</tr>
											</tbody>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">1</td>
												<td >Digital Assessment-1</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
																						
												<span>20 Jan 2026 03:09 PM</span>
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="DA01"></input> <input
															type="hidden" name="opt" value="Digital Assessment-1"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000667&#39;,
												&#39;DA01&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/DA01/AP2025264000667&#39;)">
														<span class="glyphicon glyphicon-download-alt"></span>														
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">2</td>
												<td >Digital Assessment-2</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="DA02"></input> <input
															type="hidden" name="opt" value="Digital Assessment-2"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000667&#39;,
												&#39;DA02&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/DA02/AP2025264000667&#39;)">
																												
														</a>
												</td>	


											</tr>


										</table>

									</div>
									
							<div class="modal" id="myModal" role="dialog">
								<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-bs-dismiss="modal">&times;</button>
											<h4 class="modal-title">File Upload</h4>
										</div>
										<div class="modal-body">
											<embed id="tes"  width="100%" height="400px" />
										</div>
										<div class="modal-footer">

											<button type="button" class="btn btn-default"
												data-bs-dismiss="modal">confirm</button>

											<button type="button" class="btn btn-default" id="close"
												data-bs-dismiss="modal">close</button>


										</div>
									</div>
								</div>
							</div>
							
								

									<div align="left" class="col-md-6">
										<br />
										<button type="button" class="btn btn-primary"
											onclick="javascript:reload(&#39;AP2025264&#39;);">
											Go Back</button>
									</div>
									<input type="hidden" id="success" value="" /> <input
										type="hidden" id="jsonBom" value="" />
									<script>
										/*<![CDATA[*/

										var message = document
												.getElementById("jsonBom").value;
										var success = document
												.getElementById("success").value;

										if (message != "") {
											swal(message, "", "error");
										}

										if (success != "") {
											swal(success, "", "success");
										}
										//}				 				

										/*]]>*/
									</script>

								</div>
							</div>
							<script>
								$(document).ready(function() {
									$('[data-toggle="tooltip"]').tooltip();
								});
							</script>
						</form>

					</div>
				</div>
			</div>
		</section>
		<noscript>
			<h2 class="text-red">Enable JavaScript to Access VTOP</h2>
		</noscript>
		<!-- Custom Scripts for VTOP Pages-->


		<script>
			/*<![CDATA[*/
				
				$('#studDaUpload').change(function() {
									// Initializing our modal.
					var daUploadFlag = true;
					 var uploadedFile =document.getElementById("studDaUpload").value;
					 if(uploadedFile==''){
						 swal("Kindly upload the file","", "warning");
						 daUploadFlag =  false;
					 }
				     if(uploadedFile!=''){
				          var checkimg = uploadedFile.toLowerCase();
				          
				          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
				              document.getElementById("studDaUpload").focus();
				              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
				              daUploadFlag =  false;
				           }
				            var img = document.getElementById("studDaUpload");			            
				            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
				            {			            	
				            	swal("File size (Max. upto 4MB)","", "warning");
				            	daUploadFlag =  false;
				            }			            
				      }
				     if(daUploadFlag==true)
				    	 {
				    	 	var checkimg = uploadedFile.toLowerCase();
				          
				          if (checkimg.match(/(\.pdf)$/)){ // validation of file extension using regular expression before file upload
				        	  readURL(this, 'studDaUpload');
								if (this.name == 'studDaUpload') {
									$("/#close").click(function() {
										$("/#studDaUpload").val("")
									});
								}
				           }									
				    	 }
				});
			
				function readURL(input, ch) {
					if (input.files && input.files[0]) {

						var reader = new FileReader();

						reader.onload = function(e) {

							$('#tes').attr('src',
									e.target.result);

							$('#myModal').modal('show');

						}

						reader.readAsDataURL(input.files[0]);

					}

				}
				
			function doDAssignmentProcess(classId, mode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "XXX619c2-baba-474X-a95e-b1937c33XXXX";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId + "&mode="
						+ mode+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/processDigitalAssignmentUpload",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function reload(semesterSubId) {

				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "XXX619c2-baba-474X-a95e-b1937c33XXXX";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&semesterSubId=" + semesterSubId+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/doDigitalAssignment",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function doSaveDigitalAssignment(classId, mCode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "XXX619c2-baba-474X-a95e-b1937c33XXXX";
	            fd.append(csrfName,csrfValue);

				fd.append("classId", classId);
				fd.append("mCode", mCode);
				
				var daUploadFlag = true;
				 var uploadedFile =document.getElementById("studDaUpload").value;
				 if(uploadedFile==''){
					 swal("Kindly upload the file","", "warning");
					 daUploadFlag =  false;
				 }
			     if(uploadedFile!=''){
			          var checkimg = uploadedFile.toLowerCase();
			          
			          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
			              document.getElementById("studDaUpload").focus();
			              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
			              daUploadFlag =  false;
			           }
			            var img = document.getElementById("studDaUpload");			            
			            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
			            {			            	
			            	swal("File size (Max. upto 4MB)","", "warning");
			            	daUploadFlag =  false;
			            }			            
			      }
			     if(daUploadFlag==true)
			    	 {
			    	 
			    		 $
						.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
				    	 $.ajax({
								url : "examinations/doDAssignmentUploadMethod",
								type : "POST",
								data : fd,
								cache : false,
								processData : false,
								contentType : false,
								success : function(response) {
									$.unblockUI();
									$("/#main-section").html(response);
								}
	
							});
			    	 }		
			}

			function doCancelAssgnUpload(classId) {
				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				var authorizedId="2XBCEXXXXX";
				var csrfName = "_csrf";
	            var csrfValue = "XXX619c2-baba-474X-a95e-b1937c33XXXX";
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId+"&"+csrfName+"="+csrfValue;
				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				$.ajax({
					url : "examinations/processDigitalAssignment",
					type : "POST",
					data : params,
					success : function(response) {
						$.unblockUI();

						$("/#main-section").html(response);

					}

				});
			}

			/*]]>*/
		</script>
	</div>


</body>
</html>"#;
        let result = parse_per_course_dassignments(html.to_string());
        assert_eq!(result[0].serial_number, "1");
        assert_eq!(result[0].assignment_title, "Digital Assessment-1");
        assert_eq!(result[0].max_assignment_mark, "10");
        assert_eq!(result[0].assignment_weightage_mark, "10");
        assert_eq!(result[0].due_date, "02-May-2026");
        assert_eq!(result[0].can_qp_download, false);
        assert_eq!(result[0].da_download_url, "examinations/downloadSTudentDA/DA01/AP2025264000667");
        assert_eq!(result[0].qp_download_url, "");
        assert_eq!(result[0].can_update, true);
		assert_eq!(result[0].mcode, "DA01");
		assert_eq!(result[1].mcode, "DA02");
        assert_eq!(result[0].submission_status, "20 Jan 2026 03:09 PM");
        assert_eq!(result.len(), 2);
    }

	#[test]
	fn test_parse_process_upload_assignment_response() {
		//digital assignments process upload response
		let html = r#"<!DOCTYPE html>
<!--
  Author: Prabakaran Ramu
  Date  : 23/06/2018
  Updated author : Poornima V -- 10/01/2023
-->
<html>
<!--<head th:include="layouts/header :: style_sheets">-->
<head>
<link rel="stylesheet" href="assets/css/sweetalert.css" />
<script type="text/javascript" src="assets/js/sweetalert.min.js"
	charset="utf-8"></script>
</head>

<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<div id="main-section">
		<!-- Main content -->
		<section class="content">
			<div class="col-sm-12">
				<div class="box box-info">

					<div class="box-header with-border">
						<h3 class="box-title">Assignment Upload</h3>
					</div>
					<div class="box-body">

						<form role="form" id="daUpload" name="daUpload" method="post"
							autocomplete="off">
							<input type="hidden" name="authorizedID" id="authorizedID"
								value="2XBCEXXXXX" />
							<!-- th:object="${examSchedule}"> -->
							<div class="col-md-16"
								style="margin-top: 20px; margin-left: 1px;">
								<div>

									<div align="center">
										<span
											style="color: green; font-size: 20px; font-weight: bold;"></span> <span
											style="color: red; font-size: 20px; font-weight: bold;"></span></div>

									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable" style="align: center;">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Semester</td>
													<td style="width: 12%;">Course Code</td>
													<td style="width: 30%;">Course Title</td>
													<td style="width: 12%;">Course Type</td>
													<td style="width: 10%;">Class Number</td>
												</tr>
												<tr class="fixedContent tableContent">
													<td style="width: 20%;">Winter Semester 2025-26</td>
													<td style="width: 10%;">CSE3015</td>
													<td style="width: 30%;">Natural Language Processing</td>
													<td style="width: 10%;">ELA</td>
													<td style="width: 10%;">AP2025264000697</td>
												</tr>
											</tbody>
										</table>
									</div>


									<br /> 
									
								<div class="col-md-10">
									<p style="color: red;">
										Notes:  <br /> 
										1. File size (Max. upto 4MB) <br /> 
										2. File type should be pdf,xls,xlsx,doc,docx <br /> 
									</p>
								</div>
									
									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td rowspan="2" style="width: 5%;">Sl.No.</td>
													<td rowspan="2" style="width: 20%;">Title</td>
													<td rowspan="2" style="width: 5%;">Max. Mark</td>
													<td rowspan="2" style="width: 5%;">Weightage %</td>
													<td rowspan="2" style="width: 10%;">Due Date</td>
													<td rowspan="2" style="width: 5%;">QP</td>
													<td colspan="3" style="width: 50%;">Document Details</td>
												</tr>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Last Updated On</td>
													<td style="width: 20%;">Upload/Edit</td>
													<td style="width: 20%;">Download</td>
												</tr>
											</tbody>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">1</td>
												<td >Experiment-1</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-1/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
																						
												<span>08 Jan 2026 02:53 PM</span>
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-1"></input> <input
															type="hidden" name="opt" value="Experiment-1"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-1&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-1/AP2025264000697&#39;)">
														<span class="glyphicon glyphicon-download-alt"></span>														
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">2</td>
												<td >Experiment-2</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-2/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
																						
												<span>22 Jan 2026 03:05 PM</span>
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-2"></input> <input
															type="hidden" name="opt" value="Experiment-2"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-2&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-2/AP2025264000697&#39;)">
														<span class="glyphicon glyphicon-download-alt"></span>														
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">3</td>
												<td >Experiment-3</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												<div class="col-sm-12 form-group">
														<input type="file" class="btn"
														accept=".xls,.xlsx,.pdf,.doc,.docx" id="studDaUpload"
														name="studDaUpload" required="required"
														style="display: block;" />

												</div>
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-3"></input> <input
															type="hidden" name="opt" value="Experiment-3"></input>
															<span>
																<input type="button" name="action"
																class="btn btn-primary" value="Submit"
																onclick="javascript:doSaveDigitalAssignment(&#39;AP2025264000697&#39;,
												&#39;Experiment-3&#39;);" />
																<input type="button" name="action"
																class="btn btn-primary" value="Cancel"
																onclick="javascript:doCancelAssgnUpload(&#39;AP2025264000697&#39;);" />

														</span> 


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-3/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">4</td>
												<td >Experiment-4</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-4"></input> <input
															type="hidden" name="opt" value="Experiment-4"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-4&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-4/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">5</td>
												<td >Experiment-5</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-5"></input> <input
															type="hidden" name="opt" value="Experiment-5"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-5&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-5/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">6</td>
												<td >Experiment-6</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-6"></input> <input
															type="hidden" name="opt" value="Experiment-6"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-6&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-6/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>


										</table>

									</div>
									
							<div class="modal" id="myModal" role="dialog">
								<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-bs-dismiss="modal">&times;</button>
											<h4 class="modal-title">File Upload</h4>
										</div>
										<div class="modal-body">
											<embed id="tes"  width="100%" height="400px" />
										</div>
										<div class="modal-footer">

											<button type="button" class="btn btn-default"
												data-bs-dismiss="modal">confirm</button>

											<button type="button" class="btn btn-default" id="close"
												data-bs-dismiss="modal">close</button>


										</div>
									</div>
								</div>
							</div>
							
								

									<div align="left" class="col-md-6">
										<br />
										<button type="button" class="btn btn-primary"
											onclick="javascript:reload(&#39;AP2025264&#39;);">
											Go Back</button>
									</div>
									<input type="hidden" id="success" value="" /> <input
										type="hidden" id="jsonBom" value="" />
									<script>
										/*<![CDATA[*/

										var message = document
												.getElementById("jsonBom").value;
										var success = document
												.getElementById("success").value;

										if (message != "") {
											swal(message, "", "error");
										}

										if (success != "") {
											swal(success, "", "success");
										}
										//}				 				

										/*]]>*/
									</script>

								</div>
							</div>
							<script>
								$(document).ready(function() {
									$('[data-toggle="tooltip"]').tooltip();
								});
							</script>
						</form>

					</div>
				</div>
			</div>
		</section>
		<noscript>
			<h2 class="text-red">Enable JavaScript to Access VTOP</h2>
		</noscript>
		<!-- Custom Scripts for VTOP Pages-->


		<script>
			/*<![CDATA[*/
				
				$('#studDaUpload').change(function() {
									// Initializing our modal.
					var daUploadFlag = true;
					 var uploadedFile =document.getElementById("studDaUpload").value;
					 if(uploadedFile==''){
						 swal("Kindly upload the file","", "warning");
						 daUploadFlag =  false;
					 }
				     if(uploadedFile!=''){
				          var checkimg = uploadedFile.toLowerCase();
				          
				          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
				              document.getElementById("studDaUpload").focus();
				              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
				              daUploadFlag =  false;
				           }
				            var img = document.getElementById("studDaUpload");			            
				            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
				            {			            	
				            	swal("File size (Max. upto 4MB)","", "warning");
				            	daUploadFlag =  false;
				            }			            
				      }
				     if(daUploadFlag==true)
				    	 {
				    	 	var checkimg = uploadedFile.toLowerCase();
				          
				          if (checkimg.match(/(\.pdf)$/)){ // validation of file extension using regular expression before file upload
				        	  readURL(this, 'studDaUpload');
								if (this.name == 'studDaUpload') {
									$("/#close").click(function() {
										$("/#studDaUpload").val("")
									});
								}
				           }									
				    	 }
				});
			
				function readURL(input, ch) {
					if (input.files && input.files[0]) {

						var reader = new FileReader();

						reader.onload = function(e) {

							$('#tes').attr('src',
									e.target.result);

							$('#myModal').modal('show');

						}

						reader.readAsDataURL(input.files[0]);

					}

				}
				
			function doDAssignmentProcess(classId, mode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId + "&mode="
						+ mode+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/processDigitalAssignmentUpload",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function reload(semesterSubId) {

				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&semesterSubId=" + semesterSubId+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/doDigitalAssignment",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function doSaveDigitalAssignment(classId, mCode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
	            fd.append(csrfName,csrfValue);

				fd.append("classId", classId);
				fd.append("mCode", mCode);
				
				var daUploadFlag = true;
				 var uploadedFile =document.getElementById("studDaUpload").value;
				 if(uploadedFile==''){
					 swal("Kindly upload the file","", "warning");
					 daUploadFlag =  false;
				 }
			     if(uploadedFile!=''){
			          var checkimg = uploadedFile.toLowerCase();
			          
			          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
			              document.getElementById("studDaUpload").focus();
			              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
			              daUploadFlag =  false;
			           }
			            var img = document.getElementById("studDaUpload");			            
			            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
			            {			            	
			            	swal("File size (Max. upto 4MB)","", "warning");
			            	daUploadFlag =  false;
			            }			            
			      }
			     if(daUploadFlag==true)
			    	 {
			    	 
			    		 $
						.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
				    	 $.ajax({
								url : "examinations/doDAssignmentUploadMethod",
								type : "POST",
								data : fd,
								cache : false,
								processData : false,
								contentType : false,
								success : function(response) {
									$.unblockUI();
									$("/#main-section").html(response);
								}
	
							});
			    	 }		
			}

			function doCancelAssgnUpload(classId) {
				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				var authorizedId="2XBCEXXXXX";
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId+"&"+csrfName+"="+csrfValue;
				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				$.ajax({
					url : "examinations/processDigitalAssignment",
					type : "POST",
					data : params,
					success : function(response) {
						$.unblockUI();

						$("/#main-section").html(response);

					}

				});
			}

			/*]]>*/
		</script>
	</div>


</body>
</html>"#;
		assert_eq!(parse_process_upload_assignment_response(html.to_string())[0][1],"Experiment-2");
	}

	#[test]
	fn test_parse_upload_assignment_response() {
		//digital assignments upload response
		let html = r#"<!DOCTYPE html>
<!--
  Author: Prabakaran Ramu
  Date  : 23/06/2018
  Updated author : Poornima V -- 10/01/2023
-->
<html>
<!--<head th:include="layouts/header :: style_sheets">-->
<head>
<link rel="stylesheet" href="assets/css/sweetalert.css" />
<script type="text/javascript" src="assets/js/sweetalert.min.js"
	charset="utf-8"></script>
</head>

<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<div id="main-section">
		<!-- Main content -->
		<section class="content">
			<div class="col-sm-12">
				<div class="box box-info">

					<div class="box-header with-border">
						<h3 class="box-title">Assignment Upload</h3>
					</div>
					<div class="box-body">

						<form role="form" id="daUpload" name="daUpload" method="post"
							autocomplete="off">
							<input type="hidden" name="authorizedID" id="authorizedID"
								value="2XBCEXXXXX" />
							<!-- th:object="${examSchedule}"> -->
							<div class="col-md-16"
								style="margin-top: 20px; margin-left: 1px;">
								<div>

									<div align="center">
										<span
											style="color: green; font-size: 20px; font-weight: bold;">Uploaded successfully</span> <span
											style="color: red; font-size: 20px; font-weight: bold;"></span></div>

									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable" style="align: center;">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Semester</td>
													<td style="width: 12%;">Course Code</td>
													<td style="width: 30%;">Course Title</td>
													<td style="width: 12%;">Course Type</td>
													<td style="width: 10%;">Class Number</td>
												</tr>
												<tr class="fixedContent tableContent">
													<td style="width: 20%;">Winter Semester 2025-26</td>
													<td style="width: 10%;">CSE3015</td>
													<td style="width: 30%;">Natural Language Processing</td>
													<td style="width: 10%;">ELA</td>
													<td style="width: 10%;">AP2025264000697</td>
												</tr>
											</tbody>
										</table>
									</div>


									<br /> 
									
								<div class="col-md-10">
									<p style="color: red;">
										Notes:  <br /> 
										1. File size (Max. upto 4MB) <br /> 
										2. File type should be pdf,xls,xlsx,doc,docx <br /> 
									</p>
								</div>
									
									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td rowspan="2" style="width: 5%;">Sl.No.</td>
													<td rowspan="2" style="width: 20%;">Title</td>
													<td rowspan="2" style="width: 5%;">Max. Mark</td>
													<td rowspan="2" style="width: 5%;">Weightage %</td>
													<td rowspan="2" style="width: 10%;">Due Date</td>
													<td rowspan="2" style="width: 5%;">QP</td>
													<td colspan="3" style="width: 50%;">Document Details</td>
												</tr>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Last Updated On</td>
													<td style="width: 20%;">Upload/Edit</td>
													<td style="width: 20%;">Download</td>
												</tr>
											</tbody>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">1</td>
												<td >Experiment-1</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-1/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
																						
												<span>08 Jan 2026 02:53 PM</span>
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-1"></input> <input
															type="hidden" name="opt" value="Experiment-1"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-1&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-1/AP2025264000697&#39;)">
														<span class="glyphicon glyphicon-download-alt"></span>														
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">2</td>
												<td >Experiment-2</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-2/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
																						
												<span>22 Jan 2026 03:05 PM</span>
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-2"></input> <input
															type="hidden" name="opt" value="Experiment-2"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-2&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-2/AP2025264000697&#39;)">
														<span class="glyphicon glyphicon-download-alt"></span>														
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">3</td>
												<td >Experiment-3</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-3/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
																						
												<span>25 Jan 2026 11:59 AM</span>
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-3"></input> <input
															type="hidden" name="opt" value="Experiment-3"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-3&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-3/AP2025264000697&#39;)">
														<span class="glyphicon glyphicon-download-alt"></span>														
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">4</td>
												<td >Experiment-4</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-4/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-4"></input> <input
															type="hidden" name="opt" value="Experiment-4"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-4&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-4/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">5</td>
												<td >Experiment-5</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-5/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-5"></input> <input
															type="hidden" name="opt" value="Experiment-5"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-5&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-5/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">6</td>
												<td >Experiment-6</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>
												<td style=" vertical-align: middle; text-align: center;">10</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">02-May-2026</span> 
												</td>
												<td><span> <a
														class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/doDownloadQuestion/Experiment-6/AP2025264000697&#39;)">
															<span class="glyphicon glyphicon-download-alt"></span>
													</a></span></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="Experiment-6"></input> <input
															type="hidden" name="opt" value="Experiment-6"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2025264000697&#39;,
												&#39;Experiment-6&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/Experiment-6/AP2025264000697&#39;)">
																												
														</a>
												</td>	


											</tr>


										</table>

									</div>
									
							<div class="modal" id="myModal" role="dialog">
								<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-bs-dismiss="modal">&times;</button>
											<h4 class="modal-title">File Upload</h4>
										</div>
										<div class="modal-body">
											<embed id="tes"  width="100%" height="400px" />
										</div>
										<div class="modal-footer">

											<button type="button" class="btn btn-default"
												data-bs-dismiss="modal">confirm</button>

											<button type="button" class="btn btn-default" id="close"
												data-bs-dismiss="modal">close</button>


										</div>
									</div>
								</div>
							</div>
							
								

									<div align="left" class="col-md-6">
										<br />
										<button type="button" class="btn btn-primary"
											onclick="javascript:reload(&#39;AP2025264&#39;);">
											Go Back</button>
									</div>
									<input type="hidden" id="success" value="Uploaded successfully" /> <input
										type="hidden" id="jsonBom" value="" />
									<script>
										/*<![CDATA[*/

										var message = document
												.getElementById("jsonBom").value;
										var success = document
												.getElementById("success").value;

										if (message != "") {
											swal(message, "", "error");
										}

										if (success != "") {
											swal(success, "", "success");
										}
										//}				 				

										/*]]>*/
									</script>

								</div>
							</div>
							<script>
								$(document).ready(function() {
									$('[data-toggle="tooltip"]').tooltip();
								});
							</script>
						</form>

					</div>
				</div>
			</div>
		</section>
		<noscript>
			<h2 class="text-red">Enable JavaScript to Access VTOP</h2>
		</noscript>
		<!-- Custom Scripts for VTOP Pages-->


		<script>
			/*<![CDATA[*/
				
				$('#studDaUpload').change(function() {
									// Initializing our modal.
					var daUploadFlag = true;
					 var uploadedFile =document.getElementById("studDaUpload").value;
					 if(uploadedFile==''){
						 swal("Kindly upload the file","", "warning");
						 daUploadFlag =  false;
					 }
				     if(uploadedFile!=''){
				          var checkimg = uploadedFile.toLowerCase();
				          
				          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
				              document.getElementById("studDaUpload").focus();
				              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
				              daUploadFlag =  false;
				           }
				            var img = document.getElementById("studDaUpload");			            
				            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
				            {			            	
				            	swal("File size (Max. upto 4MB)","", "warning");
				            	daUploadFlag =  false;
				            }			            
				      }
				     if(daUploadFlag==true)
				    	 {
				    	 	var checkimg = uploadedFile.toLowerCase();
				          
				          if (checkimg.match(/(\.pdf)$/)){ // validation of file extension using regular expression before file upload
				        	  readURL(this, 'studDaUpload');
								if (this.name == 'studDaUpload') {
									$("/#close").click(function() {
										$("/#studDaUpload").val("")
									});
								}
				           }									
				    	 }
				});
			
				function readURL(input, ch) {
					if (input.files && input.files[0]) {

						var reader = new FileReader();

						reader.onload = function(e) {

							$('#tes').attr('src',
									e.target.result);

							$('#myModal').modal('show');

						}

						reader.readAsDataURL(input.files[0]);

					}

				}
				
			function doDAssignmentProcess(classId, mode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId + "&mode="
						+ mode+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/processDigitalAssignmentUpload",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function reload(semesterSubId) {

				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&semesterSubId=" + semesterSubId+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/doDigitalAssignment",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function doSaveDigitalAssignment(classId, mCode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
	            fd.append(csrfName,csrfValue);

				fd.append("classId", classId);
				fd.append("mCode", mCode);
				
				var daUploadFlag = true;
				 var uploadedFile =document.getElementById("studDaUpload").value;
				 if(uploadedFile==''){
					 swal("Kindly upload the file","", "warning");
					 daUploadFlag =  false;
				 }
			     if(uploadedFile!=''){
			          var checkimg = uploadedFile.toLowerCase();
			          
			          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
			              document.getElementById("studDaUpload").focus();
			              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
			              daUploadFlag =  false;
			           }
			            var img = document.getElementById("studDaUpload");			            
			            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
			            {			            	
			            	swal("File size (Max. upto 4MB)","", "warning");
			            	daUploadFlag =  false;
			            }			            
			      }
			     if(daUploadFlag==true)
			    	 {
			    	 
			    		 $
						.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
				    	 $.ajax({
								url : "examinations/doDAssignmentUploadMethod",
								type : "POST",
								data : fd,
								cache : false,
								processData : false,
								contentType : false,
								success : function(response) {
									$.unblockUI();
									$("/#main-section").html(response);
								}
	
							});
			    	 }		
			}

			function doCancelAssgnUpload(classId) {
				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				var authorizedId="2XBCEXXXXX";
				var csrfName = "_csrf";
	            var csrfValue = "d05cf432-9433-XXXX-XXXX-3b9374573a77";
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId+"&"+csrfName+"="+csrfValue;
				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				$.ajax({
					url : "examinations/processDigitalAssignment",
					type : "POST",
					data : params,
					success : function(response) {
						$.unblockUI();

						$("/#main-section").html(response);

					}

				});
			}

			/*]]>*/
		</script>
	</div>


</body>
</html>
	"#;

		let html1 = r#"<!DOCTYPE html>
<!--
  Author: Prabakaran Ramu
  Date  : 23/06/2018
  Updated author : Poornima V -- 10/01/2023
-->
<html>
<!--<head th:include="layouts/header :: style_sheets">-->
<head>
<link rel="stylesheet" href="assets/css/sweetalert.css" />
<script type="text/javascript" src="assets/js/sweetalert.min.js"
	charset="utf-8"></script>
</head>

<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<div id="main-section">
		<!-- Main content -->
		<section class="content">
			<div class="col-sm-12">
				<div class="box box-info">

					<div class="box-header with-border">
						<h3 class="box-title">Assignment Upload</h3>
					</div>
					<div class="box-body">

						<form role="form" id="daUpload" name="daUpload" method="post"
							autocomplete="off">
							<input type="hidden" name="authorizedID" id="authorizedID"
								value="2XBCEXXXXX" />
							<!-- th:object="${examSchedule}"> -->
							<div class="col-md-16"
								style="margin-top: 20px; margin-left: 1px;">
								<div>

									<div align="center">
										<span
											style="color: green; font-size: 20px; font-weight: bold;"></span> <span
											style="color: red; font-size: 20px; font-weight: bold;">Upload Restricted Mark Awarded</span></div>

									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable" style="align: center;">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Semester</td>
													<td style="width: 12%;">Course Code</td>
													<td style="width: 30%;">Course Title</td>
													<td style="width: 12%;">Course Type</td>
													<td style="width: 10%;">Class Number</td>
												</tr>
												<tr class="fixedContent tableContent">
													<td style="width: 20%;">Winter Semester 2024-25</td>
													<td style="width: 10%;">EXC1007</td>
													<td style="width: 30%;">Quiz Club</td>
													<td style="width: 10%;">NCC</td>
													<td style="width: 10%;">AP2024254001399</td>
												</tr>
											</tbody>
										</table>
									</div>


									<br /> 
									
								<div class="col-md-10">
									<p style="color: red;">
										Notes:  <br /> 
										1. File size (Max. upto 4MB) <br /> 
										2. File type should be pdf,xls,xlsx,doc,docx <br /> 
									</p>
								</div>
									
									<div id="fixedTableContainer" class="fixedTableContainer">
										<table class="customTable">
											<tbody>
												<tr class="fixedContent tableHeader">
													<td rowspan="2" style="width: 5%;">Sl.No.</td>
													<td rowspan="2" style="width: 20%;">Title</td>
													<td rowspan="2" style="width: 5%;">Max. Mark</td>
													<td rowspan="2" style="width: 5%;">Weightage %</td>
													<td rowspan="2" style="width: 10%;">Due Date</td>
													<td rowspan="2" style="width: 5%;">QP</td>
													<td colspan="3" style="width: 50%;">Document Details</td>
												</tr>
												<tr class="fixedContent tableHeader">
													<td style="width: 20%;">Last Updated On</td>
													<td style="width: 20%;">Upload/Edit</td>
													<td style="width: 20%;">Download</td>
												</tr>
											</tbody>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">1</td>
												<td >Event-1</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">-</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="AST01"></input> <input
															type="hidden" name="opt" value="Event-1"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2024254001399&#39;,
												&#39;AST01&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/AST01/AP2024254001399&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">2</td>
												<td >Event-2</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">-</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="AST02"></input> <input
															type="hidden" name="opt" value="Event-2"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2024254001399&#39;,
												&#39;AST02&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/AST02/AP2024254001399&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">3</td>
												<td >Event-3</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">-</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="AST03"></input> <input
															type="hidden" name="opt" value="Event-3"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2024254001399&#39;,
												&#39;AST03&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/AST03/AP2024254001399&#39;)">
																												
														</a>
												</td>	


											</tr>

											<tr class="fixedContent tableContent">
												<td style=" vertical-align: middle; text-align: center;">4</td>
												<td >Event-4</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>
												<td style=" vertical-align: middle; text-align: center;">25</td>

												<td
													style=" vertical-align: middle; text-align: center;">
													<span style="color: green;">-</span> 
												</td>
												<td></td>
													
												<td style=" text-align: center;">
												
												<span style="color: green;"></span>										
												
													</td>
													
												
												<td style=" text-align: center;">
												
												<br/>
												 <span>
														<span> <input
															type="hidden" name="code"
															value="AST04"></input> <input
															type="hidden" name="opt" value="Event-4"></input>
															 <span>
																<button type="button" class="icon-button"
																	style="vertical-align: middle; text-align: center;"
																	onclick="javascript:doDAssignmentProcess(&#39;AP2024254001399&#39;,
												&#39;AST04&#39;);">
																	<span
																		class="glyphicon glyphicon-pencil glyphiconDefault"></span>
																</button>
														</span>


													</span>
												</span>
												</td>
	
												<td style=" text-align: center;">
													 <a class="btn btn-link"
														href="javascript:vtopDownload(&#39;examinations/downloadSTudentDA/AST04/AP2024254001399&#39;)">
																												
														</a>
												</td>	


											</tr>


										</table>

									</div>
									
							<div class="modal" id="myModal" role="dialog">
								<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-bs-dismiss="modal">&times;</button>
											<h4 class="modal-title">File Upload</h4>
										</div>
										<div class="modal-body">
											<embed id="tes"  width="100%" height="400px" />
										</div>
										<div class="modal-footer">

											<button type="button" class="btn btn-default"
												data-bs-dismiss="modal">confirm</button>

											<button type="button" class="btn btn-default" id="close"
												data-bs-dismiss="modal">close</button>


										</div>
									</div>
								</div>
							</div>
							
								

									<div align="left" class="col-md-6">
										<br />
										<button type="button" class="btn btn-primary"
											onclick="javascript:reload(&#39;AP2024254&#39;);">
											Go Back</button>
									</div>
									<input type="hidden" id="success" value="" /> <input
										type="hidden" id="jsonBom" value="Upload Restricted Mark Awarded" />
									<script>
										/*<![CDATA[*/

										var message = document
												.getElementById("jsonBom").value;
										var success = document
												.getElementById("success").value;

										if (message != "") {
											swal(message, "", "error");
										}

										if (success != "") {
											swal(success, "", "success");
										}
										//}				 				

										/*]]>*/
									</script>

								</div>
							</div>
							<script>
								$(document).ready(function() {
									$('[data-toggle="tooltip"]').tooltip();
								});
							</script>
						</form>

					</div>
				</div>
			</div>
		</section>
		<noscript>
			<h2 class="text-red">Enable JavaScript to Access VTOP</h2>
		</noscript>
		<!-- Custom Scripts for VTOP Pages-->


		<script>
			/*<![CDATA[*/
				
				$('#studDaUpload').change(function() {
									// Initializing our modal.
					var daUploadFlag = true;
					 var uploadedFile =document.getElementById("studDaUpload").value;
					 if(uploadedFile==''){
						 swal("Kindly upload the file","", "warning");
						 daUploadFlag =  false;
					 }
				     if(uploadedFile!=''){
				          var checkimg = uploadedFile.toLowerCase();
				          
				          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
				              document.getElementById("studDaUpload").focus();
				              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
				              daUploadFlag =  false;
				           }
				            var img = document.getElementById("studDaUpload");			            
				            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
				            {			            	
				            	swal("File size (Max. upto 4MB)","", "warning");
				            	daUploadFlag =  false;
				            }			            
				      }
				     if(daUploadFlag==true)
				    	 {
				    	 	var checkimg = uploadedFile.toLowerCase();
				          
				          if (checkimg.match(/(\.pdf)$/)){ // validation of file extension using regular expression before file upload
				        	  readURL(this, 'studDaUpload');
								if (this.name == 'studDaUpload') {
									$("/#close").click(function() {
										$("/#studDaUpload").val("")
									});
								}
				           }									
				    	 }
				});
			
				function readURL(input, ch) {
					if (input.files && input.files[0]) {

						var reader = new FileReader();

						reader.onload = function(e) {

							$('#tes').attr('src',
									e.target.result);

							$('#myModal').modal('show');

						}

						reader.readAsDataURL(input.files[0]);

					}

				}
				
			function doDAssignmentProcess(classId, mode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "78022e35-e8c1-XXXX-XXXX-e7705a734ce7";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId + "&mode="
						+ mode+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/processDigitalAssignmentUpload",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function reload(semesterSubId) {

				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "78022e35-e8c1-XXXX-XXXX-e7705a734ce7";
	            fd.append(csrfName,csrfValue);

				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&semesterSubId=" + semesterSubId+"&"+csrfName+"="+csrfValue;

				$.ajax({
					url : "examinations/doDigitalAssignment",
					type : "POST",
					data : params,

					success : function(response) {
						$.unblockUI();
						$("/#main-section").html(response);

					}

				});
			}

			function doSaveDigitalAssignment(classId, mCode) {
				var myform = document.getElementById("daUpload");
				var fd = new FormData(myform);
				var csrfName = "_csrf";
	            var csrfValue = "78022e35-e8c1-XXXX-XXXX-e7705a734ce7";
	            fd.append(csrfName,csrfValue);

				fd.append("classId", classId);
				fd.append("mCode", mCode);
				
				var daUploadFlag = true;
				 var uploadedFile =document.getElementById("studDaUpload").value;
				 if(uploadedFile==''){
					 swal("Kindly upload the file","", "warning");
					 daUploadFlag =  false;
				 }
			     if(uploadedFile!=''){
			          var checkimg = uploadedFile.toLowerCase();
			          
			          if (!checkimg.match(/(\.pdf|\.xls|\.xlsx|\.doc|\.docx)$/)){ // validation of file extension using regular expression before file upload
			              document.getElementById("studDaUpload").focus();
			              swal("File type should be pdf,xls,xlsx,doc,docx","", "warning");
			              daUploadFlag =  false;
			           }
			            var img = document.getElementById("studDaUpload");			            
			            if(uploadedFile!='' && img.files[0].size > 4194304)  // validation according to file size
			            {			            	
			            	swal("File size (Max. upto 4MB)","", "warning");
			            	daUploadFlag =  false;
			            }			            
			      }
			     if(daUploadFlag==true)
			    	 {
			    	 
			    		 $
						.blockUI({
							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});
				    	 $.ajax({
								url : "examinations/doDAssignmentUploadMethod",
								type : "POST",
								data : fd,
								cache : false,
								processData : false,
								contentType : false,
								success : function(response) {
									$.unblockUI();
									$("/#main-section").html(response);
								}
	
							});
			    	 }		
			}

			function doCancelAssgnUpload(classId) {
				var authorizedID = document.getElementById("authorizedID").value;
				var now = new Date();
				var authorizedId="2XBCEXXXXX";
				var csrfName = "_csrf";
	            var csrfValue = "78022e35-e8c1-XXXX-XXXX-e7705a734ce7";
				params = "authorizedID=" + authorizedID + "&x="
						+ now.toUTCString() + "&classId=" + classId+"&"+csrfName+"="+csrfValue;
				$
						.blockUI({

							message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
						});

				$.ajax({
					url : "examinations/processDigitalAssignment",
					type : "POST",
					data : params,
					success : function(response) {
						$.unblockUI();

						$("/#main-section").html(response);

					}

				});
			}

			/*]]>*/
		</script>
	</div>


</body>
</html>	"#;

		let html2 = r#"<!DOCTYPE html>
<!--
 Author: Packialakshmi V
 Date  : 08/10/2018
-->
<html>
<head>
<script type="text/javascript" src="assets/js/jquery.validationEngine.js"charset="utf-8"></script>
<script type="text/javascript" src="assets/js/jquery.validationEngine-en.js"charset="utf-8"></script>
</head>
<body class="hold-transition skin-blue-light sidebar-mini fixed">
	<div id="main-section">
		<section class="content">
			<div class="col-sm-12">
				<div class="box box-info">

					<div class="box-header with-border">
						<h3 class="box-title">Assignment Upload - File modification
							verification code</h3>
					</div>

					<div class="box-body">
						<form role="form" method="post" name="daUploadOtpAlert"
							id="daUploadOtpAlert" autocomplete="off">
							<input type="hidden" name="authorizedID" id="authorizedID"
								value="2XBCEXXXXX" />
							<div class="col-md-12" >


								<div id="fixedTableContainer" class="fixedTableContainer">
									<table class="customTable" style="align: center; width: 70%;">
										<tbody>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">Semester</td>
												<td style="width: 70%;">Winter Semester 2025-26</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">Course Code</td>
												<td style="width: 70%;">CSE3015</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">Course Title</td>
												<td style="width: 70%;">Natural Language Processing</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">Course Type</td>
												<td style="width: 70%;">ELA</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">Class Id</td>
												<td style="width: 70%;">AP2025264000697</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">Faculty</td>
												<td style="width: 70%;">70459-Chirra Venkata Ramireddy</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">File Name</td>
												<td style="width: 70%;">2XBCEXXXXX_AP2025264000697_Experiment-2.pdf</td>
											</tr>
											<tr class="tableContent">
												<td style="width: 30%;" class="panelHead textAlignCharVarying">OTP</td>
												<td>
													<div class="col-sm-2">
														<output
															style="font-weight: bold; text-align: right !important;"
															class="control-label" id="otpIdCode">xx -</output>
													</div>
													<div class="col-sm-5">
														<input style="text-align: left;" type="text"
															class="form-control bg-default" id="otpEmail"
															name="otpEmail" required="required" placeholder="OTP"
															maxlength="6" />
													</div>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								<div>
									<p class="box-title" style="color: red;font-size: 16px;">
										Any update to existing document requires OTP authentication,
										Kindly enter 6 digit OTP sent to your email ID <span
											style="font-weight: bold;">ta*************@vitapstudent.ac.in</span>
									</p>
								</div>
								<br>
								<div>
									<span class="col-sm-12 col-md-12"
										style="font-size: 20px; color: green; text-align: center;"></span><span
										class="col-sm-12 col-md-12"
										style="font-size: 20px; color: red; text-align: center;">Invalid OTP. Please try again.</span>
								</div>
								<div class="col-md-2 col-md-offset-2">
									<button type="button" class="btn btn-danger btn-block"
										onclick="javascript:doCancelOtpAssgnUpload(&#39;AP2025264&#39;,&#39;AP2025264000697&#39;);">
										<i class="fa fa-fw fa-close"></i>Cancel
									</button>
								</div>
								<div class="col-md-2 ">
									<button type="submit" class="btn btn-success btn-block">
										<i class=" fa fa-fw fa-check"></i> Submit
									</button>

								</div>

							</div>

						</form>
					</div>
				</div>
			</div>

			<noscript>
				<h2 class="text-red">Enable JavaScript to Access VTOP</h2>
			</noscript>
			<script type="text/javascript">
				/*<![CDATA[*/

				jQuery(document).ready(function() {
					jQuery("/#daUploadOtpAlert").validationEngine('attach', {
						autoHidePrompt : true,
						binded : false,
						onValidationComplete : function(form, status) {
							if (status) {
								doDAssignmentOtpUpload();
							}

						}
					});
				});

				function doCancelOtpAssgnUpload(semesterSubId, classId) {
					var authorizedID = document.getElementById("authorizedID").value;
					var now = new Date();
					var authorizedId="2XBCEXXXXX";
				    var csrfName = "_csrf";
	                var csrfValue = "9652e73b-XXXX-XXXX-afb1-970ea121238c";
					params = "authorizedID=" + authorizedID + "&x="
							+ now.toUTCString() + "&classId=" + classId+"&"+csrfName+"="+csrfValue;
					$
							.blockUI({

								message : '<img src="assets/img/482.GIF"> loading... Just a moment...'
							});

					$.ajax({
						url : "examinations/processDigitalAssignment",
						type : "POST",
						data : params,
						success : function(response) {
							$.unblockUI();

							$("/#main-section").html(response);

						}

					});
				};

				function doDAssignmentOtpUpload() {

					var myform = document.getElementById("daUploadOtpAlert");
					var fd = new FormData(myform);
					var csrfName = "_csrf";
		            var csrfValue = "9652e73b-XXXX-XXXX-afb1-970ea121238c";
		            fd.append(csrfName,csrfValue);

					$
							.blockUI({
								message : '<img src="assets/img/482.GIF"> Loading... Just a moment...'
							});
					$.ajax({
						url : "examinations/doDAssignmentOtpUpload",
						type : "POST",
						data : fd,
						cache : false,
						processData : false,
						contentType : false,
						success : function(response) {
							$.unblockUI();
							$("/#main-section").html(response);
						},
						error : function(jqXHR, textStatus, errorMessage) {
							$.unblockUI();
							$("/#upload-file-message").text(
									errorMessage + "Error while Submitting");
						}
					});
				};

				/*]]>*/
			</script>

		</section>
		<!-- /.content -->
	</div>
</body>
</html>"#;

		assert_eq!(parse_upload_assignment_response(html.to_string()), "Uploaded successfully");
		assert_eq!(parse_upload_assignment_response(html1.to_string()), "Upload Restricted Mark Awarded");
		assert_eq!(parse_upload_assignment_response(html2.to_string()), "Invalid OTP. Please try again.");

	}

