with Swarm_Structures_Base;      use Swarm_Structures_Base;
with Real_Type;                  use Real_Type;
with Vehicle_Message_Type;       use Vehicle_Message_Type;

package get_positions is
   protected Protected_Element is
      function CalculateDistance (Pos1, Pos2 : Positions) return Real;
      function find_nearest_globe (Current_Position : Positions; Globes : Energy_Globes; Globe_num : Integer) return Integer;
      procedure update_survive_list (MyMessage : in out Inter_Vehicle_Messages; GetMessage : Inter_Vehicle_Messages; Vehicle_no : Positive);
   end Protected_Element;
end get_positions;
