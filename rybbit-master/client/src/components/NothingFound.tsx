import { PlusCircle } from "lucide-react";

export function NothingFound({
  title,
  description,
  action,
  icon,
}: {
  title: string;
  description?: string;
  action?: React.ReactNode;
  icon?: React.ReactNode;
}) {
  return (
    <div className="flex flex-col items-center justify-center py-10 text-center">
      {icon && (
        <div className="bg-neutral-100 dark:bg-neutral-800 rounded-full p-3 mb-4">
          {icon}
        </div>
      )}
      <h3 className="text-lg font-medium mb-2">{title}</h3>
      {description && (
        <p className="text-neutral-500 max-w-md mb-6">{description}</p>
      )}
      {action && action}
    </div>
  );
}
