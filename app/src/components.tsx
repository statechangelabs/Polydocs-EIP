import { FC, ReactNode } from "react";
import { ErrorMessage, Field, useField } from "formik";

export const Checkbox: FC<{
  name: string;
  title: string;
  subTitle?: string;
  disabled?: boolean;
}> = ({ name, title, subTitle, disabled = false }) => {
  const [{ value }, , { setValue }] = useField(name);
  return (
    <div className="flex items-start col-span-6">
      <div className="flex h-5 items-center">
        <Field
          id={name}
          name={name}
          type="checkbox"
          className="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
          disabled={disabled}
        />
      </div>
      <div className="ml-3 text-sm">
        <label
          htmlFor="comments"
          className="font-medium text-gray-700"
          onClick={() => {
            setValue(!value);
          }}
        >
          {title}
        </label>
        {subTitle && <p className="text-gray-500 ">{subTitle}</p>}
      </div>
      <ErrorMessage name={name} />
    </div>
  );
};

export const TextField: FC<{
  name: string;
  title: string;
  subTitle?: string | ReactNode;
}> = ({ name, title, subTitle }) => {
  return (
    <div className="col-span-6 text-sm">
      <label
        htmlFor="street-address"
        className="block text-sm font-medium text-gray-700"
      >
        {title}
      </label>
      {subTitle && <p className="text-gray-500 ">{subTitle}</p>}

      <Field
        type="text"
        name={name}
        id={name}
        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
      />

      <ErrorMessage name={name}>
        {(message) => (
          <div className="pl-2 pt-2 text-red-600 font-medium text-sm">
            {message}
          </div>
        )}
      </ErrorMessage>
    </div>
  );
};

export const PasswordField: FC<{
  name: string;
  title: string;
  subTitle?: string | ReactNode;
}> = ({ name, title, subTitle }) => {
  return (
    <div className="col-span-6 text-sm">
      <label
        htmlFor="street-address"
        className="block text-sm font-medium text-gray-700"
      >
        {title}
      </label>
      {subTitle && <p className="text-gray-500 ">{subTitle}</p>}

      <Field
        type="password"
        name={name}
        id={name}
        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
      />

      <ErrorMessage name={name}>
        {(message) => (
          <div className="pl-2 pt-2 text-red-600 font-medium text-sm">
            {message}
          </div>
        )}
      </ErrorMessage>
    </div>
  );
};
