package edu.wpi.fh2t.servlets;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.bson.Document;

import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Iterator;
import java.util.ResourceBundle;

public class getTeachers extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getTeachers() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();

		String colorName = "Gray";
		if (request.getParameter("tablecolor") != null) {
			colorName = request.getParameter("tablecolor");
		}

		String level="";
		if (request.getParameter("level") != null) {
			level = request.getParameter("level");
		}

		String filter="";
		if (request.getParameter("filter") != null) {
			filter = request.getParameter("filter") + "%";
		}
		else {
			filter = "FS06%";
		}
		
		logger.debug("getTeachers servlet using filter: " + filter);			

		
		String strClassIDs = "";
		String str = "";

		
//		str = "<div class='row'><div class='col-4'><h4>" + rb.getString("students") + "</h4></div></div><div class='row'><div class='col-2'><h4></h4></div><div class='col-8'><button type='button' class='btn btn-danger btn-sm ml-1 ' onclick='resetStudents()'>" + rb.getString("reset") + "</div><div class='col-2'><h4></h4></div></div><div class='row'><div class='col-4'>";	
		str = "<div class='row'><div class='selection-header'><h4>" + rb.getString("teachers") + "</h4></div></div><div class='row'><div class='col-4'>";	
		out.print(str);
		out.print("<div><select id='teachersSelections' class='custom-select' size='8' min-width:90%; onchange=setTeacher();>");

		str = "";
//		String query = "select studentID as SID, username, currentClass as Class from usernames WHERE studentID like '" + filter + "' and not currentClass = '';";		
		Connection con = null;
		try {
			
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("iesdbUrl"),(String) getServletContext().getInitParameter("iesdbUser"),(String) getServletContext().getInitParameter("iesdbPwd"));
			
			String query = "select distinct studentID from usernames where studentID like '" + filter + "' and not currentClass = '' order by studentID";
			logger.debug("query=" + query);
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
//			pstmt.setString(1, filter);
			ResultSet rs = pstmt.executeQuery(query);
			boolean needsComma = false;
			String strTeacherIDs = "";
			String teacherID = "";
			while (rs.next()) {
				teacherID = ((String) rs.getString("studentID")).substring(0,filter.length()+3);
				//logger.debug("teacherID=" + teacherID);
				//logger.debug("teacherIDs=" + strTeacherIDs);
				if (strTeacherIDs.indexOf(teacherID) == -1) {
					str += "<option style='background-color:" + colorName + ";' value='" + teacherID + "'> " + teacherID + "</option>;";
					strTeacherIDs  += teacherID;
					if (needsComma) {
						strTeacherIDs  += ",";
					}
					else {
						needsComma = true;
					}
				}
				else {
				}
		    }

		    rs.close();
		    pstmt.close();
		} //end try
		catch (ClassNotFoundException e1) {
			logger.error(e1.getMessage());
			logger.error(e1.fillInStackTrace());
		}
		catch(java.sql.SQLException e2) {
			logger.error(e2.getMessage());
			logger.error(e2.fillInStackTrace());
		}
		catch(Exception e) {
			logger.error(e.getMessage());
			logger.error(e.fillInStackTrace());
		}
		finally {
			try {
				con.close();
			}
			catch(java.sql.SQLException e) {
				logger.error(e.getMessage());
				logger.error(e.fillInStackTrace());
			}			
		}
		
		logger.debug("str=" + str);

		out.print(str);
		out.print("</select></div>");
		out.print("</div></div>");
	}
}