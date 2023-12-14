String classes = """
CREATE TABLE classes(
	id INTEGER PRIMARY key,
	name varchar(255),
	contact varchar(255),
    
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50)
);
""";
String types = """
CREATE TABLE types(
	id INTEGER PRIMARY key ,
	name varchar(255),
	name_single varchar(255),
	banner_color varchar(255),
    
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50)
);
""";
String terms = """
CREATE TABLE terms(
	id INTEGER PRIMARY key ,
	name varchar(255),
    
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50)
);
""";
String systems = """
CREATE TABLE systems(
	id INTEGER PRIMARY key ,
	name varchar(255),
    
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50)
);
""";
String subsystems = """
CREATE TABLE subsystems(
	id INTEGER PRIMARY key ,
	name varchar(255),
    
  system_id INTEGER,
    
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50),
FOREIGN KEY(system_id) REFERENCES systems(id) 
);
""";
String subjects = """
CREATE TABLE subjects( 
	id INTEGER PRIMARY key , 
	name varchar(255), 
	img varchar(255), 
	
	display INTEGER, 
	created_at varchar(50),
	updated_at varchar(50)
);
""";
String sections = """
CREATE TABLE sections(
	id INTEGER PRIMARY key ,
	name varchar(255),
  img varchar(255),
  
  subject_id INTEGER,
    
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50),
FOREIGN KEY(subject_id) REFERENCES subjects(id) 
);
""";
String units = """
CREATE TABLE units(
	id INTEGER PRIMARY key ,
	name varchar(255),
	img varchar(255),
  file varchar(255),
  indexes text,
  country varchar(255),
  
  section_id INTEGER,
  
  class_id INTEGER, 
	term_id INTEGER, 
	type_id INTEGER, 
	subsystem_id INTEGER, 
    
	favorite INTEGER DEFAULT 0,
	
	display INTEGER,
	created_at varchar(50),
	updated_at varchar(50),
FOREIGN KEY(section_id) REFERENCES sections(id),
FOREIGN KEY(class_id) REFERENCES classes(id), 
FOREIGN KEY(term_id) REFERENCES terms(id), 
FOREIGN KEY(type_id) REFERENCES types(id),
FOREIGN KEY(subsystem_id) REFERENCES subsystems(id) 
);
""";

String vSubsystems = """
CREATE VIEW vsubsystems as
SELECT *, (SELECT systems.name from systems WHERE systems.id = system_id) as system_name from subsystems;
""";
String vUnits = """
CREATE VIEW vunits as
SELECT *,
(SELECT terms.name FROM terms WHERE terms.id = term_id) as term_name,
(SELECT classes.name FROM classes WHERE classes.id = class_id) as class_name,
(SELECT types.name FROM types WHERE types.id = type_id) as type_name,
(SELECT types.name_single FROM types WHERE types.id = type_id) as type_name_single,
(SELECT types.banner_color FROM types WHERE types.id = type_id) as type_banner_color,
(SELECT sections.name FROM sections WHERE sections.id = section_id) as section_name,
(SELECT sections.img FROM sections WHERE sections.id = section_id) as section_img,
(SELECT sections.subject_id FROM sections WHERE sections.id = section_id) as subject_id,
(SELECT subjects.name FROM subjects WHERE subjects.id = (SELECT sections.subject_id FROM sections WHERE sections.id = section_id)) as subject_name,
(SELECT subjects.img FROM subjects WHERE subjects.id = (SELECT sections.subject_id FROM sections WHERE sections.id = section_id)) as subject_img,
(SELECT subsystems.name FROM subsystems WHERE subsystems.id = subsystem_id) as subsystem_name,
(SELECT systems.id FROM systems WHERE systems.id = (SELECT subsystems.system_id FROM subsystems WHERE subsystems.id = subsystem_id)) as system_id,
(SELECT systems.name FROM systems WHERE systems.id = (SELECT subsystems.system_id FROM subsystems WHERE subsystems.id = subsystem_id)) as system_name
from units;
""";

String notifications = """
CREATE TABLE notifications(
    id varchar(255) PRIMARY key,
    title varchar(255),
    body text,
    img text,
    url text,
    file_name text,
    
    done_visit INTEGER DEFAULT 0,
    created_at varchar(50)
);
""";


String alarms = """
CREATE TABLE alarms(
  id INTEGER PRIMARY key,
  name varchar(255),
  dt varchar(255),
  
  created_at varchar(50)
);
""";

String tmp = """
  CREATE TABLE tmp(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name varchar(255),
      
  detail varchar(255),
  is_show INTEGER,
  created_at varchar(50),
  updated_at varchar(50)
);
""";
