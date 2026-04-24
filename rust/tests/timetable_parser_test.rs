use lib_vtop::api::vtop::parser::timetable_parser::parse_timetable;

#[test]
fn test_parse_timetable() {

    let html = r#"<div class="form-group" id="getStudentDetails">
								
								<div  id="studentDetailsList" >
										
									<div>
										<span style="font-size: 12px;"><b style="color: red;">Note:</b></span>
										<ul style="font-size: 12px;"> 
											<li style="text-align: justify;">Students are required to generate the invoice and then proceed to pay 
												the required course fee.  Registration is confirmed only if status of the course is 
												<Strong style="color: green;">'Registered and Approved'</Strong> (in regular cases) or 
												<Strong style="color: green;">'Registered, Invoice Generated, Fees Paid and Approved'</Strong> 
												(when there is a requirement for course fee payment).</li>
											
										</ul>
									</div><br/>
									
									<div class="table-responsive">
										<table class="table"
										style="background-color: /#fff; border: 1px solid /#ddd; font-size: 12px; padding: 4px; text-align: center;">
										<tr>
												
												<!-- <th:block th:if="${cancelbutton==2}">
													<td colspan="16" style="background-color: /#3c8dbc; border:1px solid /#b2b2b2;">
														<div class="cancle-generate">
															<button th:onclick="cancleInvoiceGenerate();"
																class="btn btn-md btn-danger btn-block"
																style="text-align: center; width: auto;
																float: none; margin: auto;">Cancel Invoice 
															</button>
														</div>
													</td>
												</th:block> -->
										</tr>
									
										
											<tr Style="background-color: /#3c8dbc; color: /#fff;border:1px solid /#b2b2b2;">
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width: 1%;">Sl.No</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width: 5%;">Class Group</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width: 20%;">Course</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:0%;">L T P J C</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:5%;">Category</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:5%;">Course Option</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:5%;">Class Nbr</th>	
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:10%;">Slot  - <br/>Venue</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:15%;">Faculty Details</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:10%;">
													Registered / Updated Date &amp; Time 
												</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:10%;">
													Attendance Date - Type</th>
												<th style="vertical-align: middle; text-align: center; border-right: 1px solid /#b2b2b2; padding: 5px; width:10%;">Status &amp; Ref No </th>
											</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">1</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">CHY1006 - Corrosion Science and Engineering</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Theory Only ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">3 0 0 0 3.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264001082</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">C1+TC1 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">220-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">Muthu Prabhu Subbaiah - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">SAS</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">16-Nov-2025 20:40</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>17-Nov-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">2</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">CSE1008 - Theory of Computation</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Theory Only ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">4 0 0 0 4.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264000377</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">B1+TB1+TBB1 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">524-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">Ravi Sankar Barpanda - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">SCOPE</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">10-Dec-2025 22:21</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>11-Dec-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">3</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">CSE3015 - Natural Language Processing</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Embedded Theory ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">3 0 0 0 3.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264000667</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">F1+TF1 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">516-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">Yelepi Usha Rani   - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">SCOPE</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">16-Nov-2025 12:56</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>17-Nov-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">4</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">CSE3015 - Natural Language Processing</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Embedded Lab ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">0 0 2 0 1.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264000697</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">L43+L44 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">414-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">Chirra Venkata Ramireddy - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">SCOPE</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">10-Dec-2025 21:25</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>11-Dec-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">5</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">CSE4004 - Web Technologies</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Embedded Theory ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">3 0 0 0 3.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264000517</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">D1+TD1 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">513-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">Nagaraju Devarakonda - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">SCOPE</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">10-Dec-2025 20:17</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>11-Dec-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">6</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">CSE4004 - Web Technologies</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Embedded Lab ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">0 0 2 0 1.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264000614</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">L55+L56 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">502C-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">Sheela jayachandran - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">SCOPE</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">30-Nov-2025 10:11</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>01-Dec-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										
										<tr>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">7</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">General (Semester)</p>
											</td>
											
											<td style="padding: 3px; font-size: 12px; border-color: /#b2b2b2;vertical-align: middle;">
												<p style="margin: 0px;">STS4006 - Advanced Competitive Coding - II</p>
												<p style="margin: 0px; font-weight: bolder;"> ( Theory Only ) </p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">3 0 0 0 3.0</p>
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												
												
													<span>-</span>
												
												
										
												
										
											
											</td>																
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">Regular</p>
																								
											</td>
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">AP2025264000131</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">E1+TE1 - </p><br/>
												<p style="margin: 0px; font-weight: bolder;">417-CB</p>
											</td>
											<td style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;">			
												
													<p style="margin: 0px;">YAMUNA DURGA A - </p><br/>
													<p style="margin: 0px; font-weight: bolder;">VISH</p>
												
																							
											</td>
											
										
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px;white-space: nowrap;">
												<p style="margin: 0px;">10-Dec-2025 20:04</p>
											</td>
											
											<td style="vertical-align: middle; border: 1px solid /#b2b2b2; padding: 3px; white-space: nowrap;">
												
												<p style="margin: 0px;">
													<span>11-Dec-2025</span><br/>
													<strong> - Manual</strong>
												</p>
											</td>
											
											<td  style="text-align:left; vertical-align: middle; border: 1px solid /#b2b2b2; border-right :2px solid /#b2b2b2; padding: 5px;">
												<p style="margin: 0px;">
													<span style="color:red;">Subject to Offering</span><br/>
													 
												</p>
												
											</td>
										</tr>
										<tr>
											<td
												style="background-color: /#3c8dbc; color: /#fff;vertical-align: middle; border: 1px solid /#b2b2b2; padding: 5px; font-size: 14px;"
												colspan="16"><span>Total Number Of Credits: </span> <b><span>18.0</span></b></td>
										</tr>
										
									<tr>
										
										<!-- <th:block th:if="${cancelbutton==2}">
											<td colspan="16" style="background-color: /#3c8dbc; border:1px solid /#b2b2b2;">
												<div class="cancle-generate">
													<button th:onclick="cancleInvoiceGenerate();"
														class="btn btn-md btn-danger btn-block"
														style="text-align: center; width: auto;
														float: none; margin: auto;">Cancel Invoice 
													</button>
												</div>
											</td>
										</th:block> -->
									</tr>
									
									</table>
									</div>						
									
	
									<div class="table table-responsive" id="ttview" style="margin-top: 20px;float: left;width: 100%;">
										 
   		 
   		 			 
   		 					  		 							
							<table id="timeTableStyle"
								class="w3-table-all w3-card-4 w3-hoverable"
								style="border: 2px solid /#3c8dbc; text-align: center; font-size: 12px; margin-bottom: 20px;width:100%;">
								
								
									
								<tr>	
									<td rowspan="2" bgcolor="/#e2e2e2"
										style="border: 1px solid /#3c8dbc; text-align: center; 
										vertical-align: middle; padding: 3px; width: 50px;">THEORY</td>
									
									<td bgcolor="/#e2e2e2"
										style="border: 1px solid /#3c8dbc; text-align: center; 
										vertical-align: middle; padding: 3px; width: 50px;">Start</td>
									
									
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">08:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">10:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">10:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">13:00</td>
											
										
										
											
										
										
										
									
										
										
											
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
											
										
										
										
									
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">15:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">15:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">17:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">17:01</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">18:00</td>
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">19:00</td>
											
										
										
											
										
										
										
									
								</tr>
								
								<tr>
									<td bgcolor="/#e2e2e2"
										style="border: 1px solid /#3c8dbc; text-align: center; 
										vertical-align: middle; padding: 3px; width: 50px;">End</td>
																		
									
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">08:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">10:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">10:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">13:50</td>
											
										
										
											
										
										
											
									
										
											
										
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
											
										
										
											
									
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">15:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">15:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">17:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">17:51</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">18:50</td>
										<td bgcolor="/#CCCCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">19:30</td>
											
										
										
											
										
										
											
									
									
								</tr>
								
									
								<tr>	
									<td rowspan="2" bgcolor="/#e2e2e2"
										style="border: 1px solid /#3c8dbc; text-align: center; 
										vertical-align: middle; padding: 3px; width: 50px;">LAB</td>
									
									<td bgcolor="/#e2e2e2"
										style="border: 1px solid /#3c8dbc; text-align: center; 
										vertical-align: middle; padding: 3px; width: 50px;">Start</td>
									
									
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">08:00</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:00</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:01</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:50</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:51</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:00</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:01</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:50</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:51</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:40</td>
											
										
										
											
										
										
										
									
										
										
											
										
										
											
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
									
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:00</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:01</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:50</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:51</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:00</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:01</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:50</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:51</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">18:00</td>
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">18:50</td>
											
										
										
											
										
										
										
									
								</tr>
								
								<tr>
									<td bgcolor="/#e2e2e2"
										style="border: 1px solid /#3c8dbc; text-align: center; 
										vertical-align: middle; padding: 3px; width: 50px;">End</td>
																		
									
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">08:50</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:50</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">09:51</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">10:40</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">10:41</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:50</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">11:51</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:40</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">12:41</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">13:30</td>
											
										
										
											
										
										
											
									
										
											
										
										
											
										
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
											
									
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:50</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">14:51</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">15:40</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">15:41</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:50</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">16:51</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">17:40</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">17:41</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">18:50</td>
										<td bgcolor="/#99CCFF"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">19:30</td>
											
										
										
											
										
										
											
									
									
								</tr>
								
								
								
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										<td rowspan="2" 
											bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">TUE</td>
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">THEORY</td>
											
										
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TFF1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">A1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">B1-CSE1008-TH-524-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TC1-CHY1006-TH-220-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">G1</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">D1-CSE4004-ETH-513-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">F2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">A2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">B2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TC2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">G2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TDD2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">LAB</td>
											
										
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L1</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L2</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L3</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L4</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L5</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L6</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L31</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L32</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L33</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L34</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L35</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L36</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
								
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										<td rowspan="2" 
											bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">WED</td>
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">THEORY</td>
											
										
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TGG1</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">D1-CSE4004-ETH-513-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">F1-CSE3015-ETH-516-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">E1-STS4006-TH-417-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">SC2</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">B1-CSE1008-TH-524-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">D2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TF2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">G2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">E2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">SC1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">B2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TCC2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">LAB</td>
											
										
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L7</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L8</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L9</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L10</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L11</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L12</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L37</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L38</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L39</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L40</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L41</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L42</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
								
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										<td rowspan="2" 
											bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">THU</td>
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">THEORY</td>
											
										
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TEE1</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">C1-CHY1006-TH-220-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TD1-CSE4004-ETH-513-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TG1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TAA1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">ECS</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TBB1-CSE1008-TH-524-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">CLUB</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TE2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">SE1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">C2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">A2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TD2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TG2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TGG2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">LAB</td>
											
										
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L13</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L14</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L15</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L16</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L17</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L18</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L43-CSE3015-ELA-414-CB-ALL</td>
													
												
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L44-CSE3015-ELA-414-CB-ALL</td>
													
												
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L45</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L46</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L47</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L48</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
								
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										<td rowspan="2" 
											bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">FRI</td>
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">THEORY</td>
											
										
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TCC1</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TB1-CSE1008-TH-524-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TA1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">F1-CSE3015-ETH-516-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TE1-STS4006-TH-417-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">SD2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">C2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TB2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TA2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">F2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TEE2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">LAB</td>
											
										
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L19</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L20</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L21</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L22</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L23</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L24</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L49</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L50</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L51</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L52</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L53</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L54</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
								
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										<td rowspan="2" 
											bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">SAT</td>
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">THEORY</td>
											
										
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TDD1</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">E1-STS4006-TH-417-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">SE2</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">C1-CHY1006-TH-220-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TF1-CSE3015-ETH-516-CB-ALL</td>
													
												
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">G1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">A1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">D2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">E2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">SD1</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TAA2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">ECS</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TBB2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">CLUB</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">TFF2</td>
													
											
												
												
													
												<td style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">-</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
										
									<tr style="background-color: /#FFFFCC;">
									
										
										<td bgcolor="/#e2e2e2"
											style="border: 1px solid /#3c8dbc; text-align: center; 
											vertical-align: middle; padding: 3px; width: 50px;">LAB</td>
											
										
										
											
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L25</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L26</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L27</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L28</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L29</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L30</td>
													
											
											
											
											
										
											
											
											
											
											<td bgcolor="/#e2e2e2"
												style="border: 1px solid /#3c8dbc; text-align: center; 
												vertical-align: middle; padding: 3px; width: 50px;">Lunch</td>
										
											
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L55-CSE4004-ELA-502C-CB-ALL</td>
													
												
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												<td bgcolor="/#CCFF33"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L56-CSE4004-ELA-502C-CB-ALL</td>
													
												
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L57</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L58</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">--</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L59</td>
													
											
												
												
													
												<td bgcolor="/#f9efa4"
														style="border: 1px solid /#3c8dbc; text-align: center; 
														vertical-align: middle; padding: 3px; width: 50px;">L60</td>
													
											
											
											
											
										
										
									</tr>
									
									
									
								
							</table>
															
										
									</div>
									
								</div>

								
							</div>"#;
    
    let time_table = parse_timetable(html.to_string());
    assert_eq!(time_table.saturday.len(), 4);
    assert_eq!(time_table.saturday[3].start_time, "14:00");
    assert_eq!(time_table.saturday[3].end_time, "15:40");
    assert_eq!(time_table.thursday[3].end_time, "15:40");
}
