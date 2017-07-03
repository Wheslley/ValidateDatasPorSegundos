/*
* @author.........: Wheslley Nycolas da Silva.
* @since..........: 03/Julho/2016 
* @parans.........: Parâmetros de entrada e saída.
* ...@p_user......: Usuário.
* ...@p_token.....: Cadeia de caracters alfanumericos.
* ...@p_ttl.......: Time To Live - Tempo de vida do token a ser gerado.
* @object.........: Function.
* @name...........: validate_token. 
*/

function validate_token ( p_user  in acesso_externo.user%type
					    , p_token in acesso_externo.token%type
						, p_ttl   in acesso_externo.ttl%type ) 
return boolean is

	w_count_acesso_externo number;
	w_count_sysdate        number;
	w_somatorio            number;
	w_status_ativo         varchar2(1) := 'A';
begin

	dbms_application_info.set_module(w_descr_obj,'validate_token');

	-- TIMESTAMP TOKEN PERSISTIDO NA MODELAGEM;
	select to_char(dt_cad - 1,'yyyy') * 31536000 +
		   to_char(dt_cad - 1,'mm') * 2678400 +
		   to_char(dt_cad - 1,'dd') * 86400 +
		   to_char(dt_cad,'hh24') * 3600 +
		   to_char(dt_cad,'mm') * 60 +
		   to_char(dt_cad,'ss')
	 into w_count_acesso_externo
	  from acesso_externo
	 where user = p_user
	   and cd_status = w_status_ativo
	   and token = p_token;

	-- TIMESTAMP DO SYSDATE;
	select to_char(sysdate - 1,'yyyy') * 31536000 +
		   to_char(sysdate - 1,'mm') * 2678400 +
		   to_char(sysdate - 1,'dd') * 86400 +
		   to_char(sysdate,'hh24') * 3600 +
		   to_char(sysdate,'mm') * 60 +
		   to_char(sysdate,'ss')
	 into w_count_sysdate
	  from dual;

	-- A SOMATÓRIA DO TIMESTAMP SYSDATE SUBTRAÍDO PELO TIMESTAMP PERSISTIDO NA MODELAGEM DEVE SER MENOR OU IGUAL A 30;
	w_somatorio := (w_count_sysdate - w_count_acesso_externo); 

	if(w_somatorio > p_ttl) then
	  return false;
	else
	  return true;
	end if;

exception  
	when others then

	  dbms_application_info.set_module(w_descr_obj,null);
	  raise_application_error(-20022, sqlerrm || ' - on validate_token');
	  
	  return false;
  
end validate_token;