-- Update delete_confide function to also delete related confide_requests
CREATE OR REPLACE FUNCTION public.delete_confide(confide_user_id_param uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  -- Delete confide for current user -> confide_user
  DELETE FROM confides
  WHERE user_id = auth.uid() AND confide_user_id = confide_user_id_param;

  -- Delete confide for confide_user -> current user
  DELETE FROM confides
  WHERE user_id = confide_user_id_param AND confide_user_id = auth.uid();

  -- Delete any confide_requests between these users (bidirectional)
  DELETE FROM confide_requests
  WHERE (sender_id = auth.uid() AND receiver_id = confide_user_id_param)
     OR (sender_id = confide_user_id_param AND receiver_id = auth.uid());
END;
$function$