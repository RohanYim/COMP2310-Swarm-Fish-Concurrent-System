-- Suggestions for packages which might be useful:

with Ada.Real_Time;         use Ada.Real_Time;
-- with Vectors_3D; use Vectors_3D;
with Swarm_Structures_Base; use Swarm_Structures_Base;
with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;

package Vehicle_Message_Type is

   -- Replace this record definition by what your vehicles need to communicate.
   package Integer_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Integer);

   use Integer_Vectors;

   type Inter_Vehicle_Messages is record

      Globe : Energy_Globes (1 .. 100);
      Globe_num : Integer;
      Get_Time : Time;
      V_charge : Vehicle_Charges;
      V_id : Positive;
      survive_list : Vector;

   end record;

end Vehicle_Message_Type;
