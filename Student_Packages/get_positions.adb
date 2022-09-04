with Vectors_3D;                 use Vectors_3D;
with Swarm_Size; use Swarm_Size;

package body get_positions is
   protected body Protected_Element is
      function CalculateDistance (Pos1, Pos2 : Positions) return Real is
         distance   : Real;
      begin
         distance := (Pos1 (x) - Pos2 (x))**2 + (Pos1 (y) - Pos2 (y))**2 + (Pos1 (z) - Pos2 (z))**2;
         return distance;
      end CalculateDistance;

      function find_nearest_globe (Current_Position : Positions; Globes : Energy_Globes; Globe_num : Integer) return Integer is
         closest_globe_index : Integer := 1;
         closest_distance : Real := CalculateDistance (Current_Position, Globes (1).Position);
         current_distance : Real;
      begin
         for i in 1 .. Globe_num loop
            current_distance := CalculateDistance (Current_Position, Globes (i).Position);

            if current_distance < closest_distance then
               closest_globe_index := i;
               closest_distance := current_distance;
            end if;
         end loop;
         return closest_globe_index;
      end find_nearest_globe;

      procedure update_survive_list (MyMessage : in out Inter_Vehicle_Messages; GetMessage : Inter_Vehicle_Messages; Vehicle_no : Positive) is
      begin
         if Integer'Value (GetMessage.survive_list.Length'Image) < Swarm_Size.Target_No_of_Elements then
            -- if M is not full, add me to the list
            if GetMessage.survive_list.Find_Index (Vehicle_no) >= 0 then
               null;
            else
               MyMessage.survive_list := GetMessage.survive_list;
               MyMessage.survive_list.Append (Vehicle_no);
            end if;
         end if;
      end update_survive_list;

   end Protected_Element;
begin
   null;
end get_positions;
